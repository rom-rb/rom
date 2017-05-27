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
        klass = Class.new(self < Repository::Root ? self : Repository::Root)
        klass.relations(name)
        klass.root(name)
        klass
      end

      # Inherits configured relations and commands
      #
      # @api private
      def inherited(klass)
        super

        return if self === Repository

        klass.relations(*relations)
        klass.commands(*commands)
      end

      # Define which relations your repository is going to use
      #
      # @example
      #   class MyRepo < ROM::Repository
      #     relations :users, :tasks
      #   end
      #
      #   my_repo = MyRepo.new(rom)
      #
      #   my_repo.users
      #   my_repo.tasks
      #
      # @return [Array<Symbol>]
      #
      # @api public
      def relations(*names)
        if names.empty?
          @relations ||= []
        else
          attr_reader(*(names - relations))
          @relations = relations | names
        end
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
      #     commands :create, plugin: :my_command_plugin
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
      def commands(*names, mapper: nil, use: nil, **opts)
        if names.any? || opts.any?
          @commands = names + opts.to_a

          @commands.each do |spec|
            type, *view = Array(spec).flatten

            if view.size > 0
              define_restricted_command_method(type, view, mapper: mapper, use: use)
            else
              define_command_method(type, mapper: mapper, use: use)
            end
          end
        else
          @commands ||= []
        end
      end

      private

      # @api private
      def define_command_method(type, **opts)
        define_method(type) do |*input|
          if input.size == 1 && input[0].respond_to?(:commit)
            changeset = input[0]
            map_tuple(changeset.relation, changeset.commit)
          else
            command(type => self.class.root, **opts).call(*input)
          end
        end
      end

      # @api private
      def define_restricted_command_method(type, views, **opts)
        views.each do |view_name|
          meth_name = views.size > 1 ? :"#{type}_#{view_name}" : type

          define_method(meth_name) do |*args|
            view_args, *input = args

            changeset = input.first

            if changeset.respond_to?(:commit)
              map_tuple(changeset.relation, changeset.commit)
            else
              command(type => self.class.root, **opts)
                .public_send(view_name, *view_args)
                .call(*input)
            end
          end
        end
      end
    end
  end
end
