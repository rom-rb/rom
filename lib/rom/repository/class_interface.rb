# frozen_string_literal: true

require "dry/core/cache"

require "rom/repository/relation_reader"

module ROM
  class Repository
    # Class-level APIs for repositories
    #
    # @api public
    module ClassInterface
      # Create a root-repository class and set its root relation
      #
      # @example
      #   # where :users is the relation name in your rom container
      #   class UserRepo < ROM::Repository[:users]
      #   end
      #
      # @param name [Symbol] The relation `register_as` value
      #
      # @return [Class] descendant of ROM::Repository::Root
      #
      # @api public
      def [](name)
        fetch_or_store(name) do
          klass = Class.new(self < Repository::Root ? self : Repository::Root)
          klass.root(name)
          klass
        end
      end

      # Initialize a new repository object, establishing configured relation proxies from
      # the passed container
      #
      # @overload new(container, **options)
      #   Initialize with container as leading parameter
      #
      #   @param [ROM::Container] container Finalized rom container
      #
      #   @param [Hash] options Repository options
      #   @option options [Module] :struct_namespace Custom struct namespace
      #   @option options [Boolean] :auto_struct Enable/Disable auto-struct mapping
      #
      # @overload new(**options)
      #   Inititalize with container as option
      #
      #   @param [Hash] options Repository options
      #   @option options [ROM::Container] :container Finalized rom container
      #   @option options [Module] :struct_namespace Custom struct namespace
      #   @option options [Boolean] :auto_struct Enable/Disable auto-struct mapping
      #
      # @api public
      def new(container = nil, **options)
        container ||= options.fetch(:container)

        unless relation_reader
          relation_reader(RelationReader.new(self, container.relation_ids))
          include(relation_reader)
        end

        super(**options, container: container)
      end

      # Inherits configured relations and commands
      #
      # @api private
      def inherited(klass)
        super

        return if self === Repository

        klass.extend(::Dry::Core::Cache)
        klass.commands(*commands)
      end

      # Defines command methods on a root repository
      #
      # @example
      #   class UserRepo < ROM::Repository[:users]
      #     commands :create, update: :by_pk, delete: :by_pk
      #   end
      #
      #   # with custom command plugin
      #   class UserRepo < ROM::Repository[:users]
      #     commands :create, use: :my_command_plugin
      #   end
      #
      #   # with custom mapper
      #   class UserRepo < ROM::Repository[:users]
      #     commands :create, mapper: :my_custom_mapper
      #   end
      #
      # @param [Array<Symbol>] names A list of command names
      # @option :mapper [Symbol] An optional mapper identifier
      # @option :use [Symbol] An optional command plugin identifier
      #
      # @return [Array<Symbol>] A list of defined command names
      #
      # @api public
      def commands(*names, mapper: nil, use: nil, plugins_options: EMPTY_HASH, **opts)
        if names.any? || opts.any?
          @commands = names + opts.to_a

          @commands.each do |spec|
            type, *view = Array(spec).flatten

            if view.empty?
              define_command_method(type, mapper: mapper, use: use,
                                          plugins_options: plugins_options)
            else
              define_restricted_command_method(type, view, mapper: mapper, use: use,
                                                           plugins_options: plugins_options)
            end
          end
        else
          @commands ||= []
        end
      end

      # @api public
      def use(plugin, **options)
        ROM.plugin_registry[:repository].fetch(plugin).apply_to(self, **options)
      end

      private

      # @api private
      def define_command_method(type, **opts)
        define_method(type) do |*input|
          if input.size == 1 && input[0].respond_to?(:commit)
            input[0].commit
          else
            root.command(type, **opts).call(*input)
          end
        end
      end

      # @api private
      def define_restricted_command_method(type, views, **opts)
        views.each do |view_name|
          meth_name = views.size > 1 ? :"#{type}_#{view_name}" : type

          define_method(meth_name) do |*args|
            arity = root.__send__(view_name).arity

            view_args = args[0..arity - 1]
            input = args[arity..args.size - 1]

            changeset = input.first

            if changeset.respond_to?(:commit)
              changeset.commit
            else
              root.public_send(view_name, *view_args).command(type, **opts).(*input)
            end
          end
        end
      end
    end
  end
end
