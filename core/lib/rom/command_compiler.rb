# frozen_string_literal: true

require 'rom/support/inflector'

require 'rom/initializer'
require 'rom/commands'
require 'rom/command_proxy'

module ROM
  # Builds commands for relations.
  #
  # This class is used by repositories to automatically create commands for
  # their relations. This is used both by `Repository#command` method and
  # `commands` repository class macros.
  #
  # @api private
  class CommandCompiler
    extend Initializer

    # @api private
    def self.registry
      Hash.new { |h, k| h[k] = {} }
    end

    # @!attribute [r] gateways
    #   @return [ROM::Registry] Gateways used for command extensions
    param :gateways

    # @!attribute [r] relations
    #   @return [ROM::RelationRegistry] Relations used with a given compiler
    param :relations

    # @!attribute [r] commands
    #   @return [ROM::Registry] Command registries with custom commands
    param :commands

    # @!attribute [r] notifications
    #   @return [Notifications::EventBus] Configuration notifications event bus
    param :notifications

    # @!attribute [r] id
    #   @return [Symbol] The command type registry identifier
    option :id, optional: true

    # @!attribute [r] adapter
    #   @return [Symbol] The adapter identifier ie :sql or :http
    option :adapter, optional: true

    # @!attribute [r] registry
    #   @return [Hash] local registry where commands will be stored during compilation
    option :registry, optional: true, default: -> { self.class.registry }

    # @!attribute [r] plugins
    #   @return [Array<Symbol>] a list of optional plugins that will be enabled for commands
    option :plugins, optional: true, default: -> { EMPTY_ARRAY }

    # @!attribute [r] plugins_options
    #   @return [Hash] a hash of options for the plugins
    option :plugins_options, optional: true, default: -> { EMPTY_HASH }

    # @!attribute [r] meta
    #   @return [Array<Symbol>] Meta data for a command
    option :meta, optional: true

    # @!attribute [r] cache
    #   @return [Cache] local cache instance
    option :cache, default: -> { Cache.new }

    # Return a specific command type for a given adapter and relation AST
    #
    # This class holds its own registry where all generated commands are being
    # stored
    #
    # CommandProxy is returned for complex command graphs as they expect root
    # relation name to be present in the input, which we don't want to have
    # in repositories. It might be worth looking into removing this requirement
    # from rom core Command::Graph API.
    #
    # @overload [](type, adapter, ast, plugins, meta)
    #   @param type [Symbol] The type of command
    #   @param adapter [Symbol] The adapter identifier
    #   @param ast [Array] The AST representation of a relation
    #   @param plugins [Array<Symbol>] A list of optional command plugins that should be used
    #   @param meta [Hash] Meta data for a command
    #
    #   @return [Command, CommandProxy]
    #
    # @api private
    def call(*args)
      cache.fetch_or_store(args.hash) do
        type, adapter, ast, plugins, plugins_options, meta = args

        compiler = with(
          id: type,
          adapter: adapter,
          plugins: Array(plugins),
          plugins_options: plugins_options,
          meta: meta
        )

        graph_opts = compiler.visit(ast)
        command = ROM::Commands::Graph.build(registry, graph_opts)

        if command.graph?
          CommandProxy.new(command)
        elsif command.lazy?
          command.unwrap
        else
          command
        end
      end
    end
    alias_method :[], :call

    # @api private
    def type
      @_type ||= Commands.const_get(Inflector.classify(id))[adapter]
    rescue NameError
      nil
    end

    # @api private
    def visit(ast, *args)
      name, node = ast
      __send__(:"visit_#{name}", node, *args)
    end

    private

    # @api private
    def visit_relation(node, parent_relation = nil)
      name, header, meta = node
      other = header.map { |attr| visit(attr, name) }.compact

      if type
        register_command(name, type, meta, parent_relation)

        default_mapping =
          if meta[:combine_type] == :many
            name
          else
            { Inflector.singularize(name).to_sym => name }
          end

        mapping =
          if parent_relation
            associations = relations[parent_relation].associations

            assoc = associations[meta[:combine_name]]

            if assoc
              { assoc.key => assoc.target.name.to_sym }
            else
              default_mapping
            end
          else
            default_mapping
          end

        if !other.empty?
          [mapping, [type, other]]
        else
          [mapping, type]
        end
      else
        registry[name][id] = commands[name][id]
        [name, id]
      end
    end

    # @api private
    def visit_attribute(*args)
      nil
    end

    # Build a command object for a specific relation
    #
    # The command will be prepared for handling associations if it's a combined
    # relation. Additional plugins will be enabled if they are configured for
    # this compiler.
    #
    # @param [Symbol] rel_name A relation identifier from the container registry
    # @param [Symbol] type The command type
    # @param [Hash] rel_meta Meta information from relation AST
    # @param [Symbol] parent_relation Optional parent relation identifier
    #
    # @return [ROM::Command]
    #
    # @api private
    def register_command(rel_name, type, rel_meta, parent_relation = nil)
      relation = relations[rel_name]

      type.create_class(rel_name, type) do |klass|
        klass.result(rel_meta.fetch(:combine_type, result))

        klass.input(meta.fetch(:input, relation.input_schema))

        meta.each do |name, value|
          klass.public_send(name, value)
        end

        setup_associates(klass, relation, rel_meta, parent_relation) if rel_meta[:combine_type]

        plugins.each do |plugin|
          plugin_options = plugins_options.fetch(plugin) { EMPTY_HASH }
          klass.use(plugin, **plugin_options)
        end

        gateway = gateways[relation.gateway]

        notifications.trigger(
          'configuration.commands.class.before_build',
          command: klass, gateway: gateway, dataset: relation.dataset, adapter: adapter
        )

        klass.extend_for_relation(relation) if klass.restrictable

        registry[rel_name][type] = klass.build(relation)
      end
    end

    # Return default result type
    #
    # @return [Symbol]
    #
    # @api private
    def result
      meta.fetch(:result, :one)
    end

    # Sets up `associates` plugin for a given command class and relation
    #
    # @param [Class] klass The command class
    # @param [Relation] relation The relation for the command
    #
    # @api private
    def setup_associates(klass, relation, meta, parent_relation)
      assoc_name =
        if relation.associations.key?(parent_relation)
          parent_relation
        else
          singular_name = Inflector.singularize(parent_relation).to_sym
          singular_name if relation.associations.key?(singular_name)
        end

      if assoc_name
        klass.associates(assoc_name)
      else
        klass.associates(parent_relation)
      end
    end
  end
end
