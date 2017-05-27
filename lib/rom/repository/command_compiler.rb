require 'dry/core/inflector'
require 'dry/core/cache'

require 'rom/commands'
require 'rom/repository/command_proxy'

module ROM
  class Repository
    # Builds commands for relations.
    #
    # This class is used by repositories to automatically create commands for
    # their relations. This is used both by `Repository#command` method and
    # `commands` repository class macros.
    #
    # @api private
    class CommandCompiler
      extend Dry::Core::Cache

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
      # @overload [](container, type, adapter, ast, plugins, options)
      #
      #   @param container [ROM::Container] container where relations are stored
      #   @param type [Symbol] The type of command
      #   @param adapter [Symbol] The adapter identifier
      #   @param ast [Array] The AST representation of a relation
      #   @param plugins [Array<Symbol>] A list of optional command plugins that should be used
      #
      #   @return [Command, CommandProxy]
      #
      # @api private
      def self.[](*args)
        fetch_or_store(args.hash) do
          container, type, adapter, ast, plugins, options = args

          graph_opts = new(type, adapter, container, registry, plugins, options).visit(ast)

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

      # @api private
      def self.registry
        @__registry__ ||= Hash.new { |h, k| h[k] = {} }
      end

      # @!attribute [r] id
      #   @return [Symbol] The command type registry identifier
      attr_reader :id

      # @!attribute [r] adapter
      #   @return [Symbol] The adapter identifier ie :sql or :http
      attr_reader :adapter

      # @!attribute [r] container
      #   @return [ROM::Container] rom container with relations and gateways
      attr_reader :container

      # @!attribute [r] registry
      #   @return [Hash] local registry where commands will be stored during compilation
      attr_reader :registry

      # @!attribute [r] plugins
      #   @return [Array<Symbol>] a list of optional plugins that will be enabled for commands
      attr_reader :plugins

      # @!attribute [r] options
      #   @return [Hash] Additional command options
      attr_reader :options

      # @api private
      def initialize(id, adapter, container, registry, plugins, options)
        @id = id
        @adapter = adapter
        @registry = registry
        @container = container
        @plugins = Array(plugins)
        @options = options
      end

      # @api private
      def type
        @_type ||= Commands.const_get(Dry::Core::Inflector.classify(id))[adapter]
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
        name, meta, header = node
        other = visit(header, name)

        if type
          register_command(name, type, meta, parent_relation)

          default_mapping =
            if meta[:combine_type] == :many
              name
            else meta[:combine_type] == :one
              { Dry::Core::Inflector.singularize(name).to_sym => name }
            end

          mapping =
            if parent_relation
              associations = container.relations[parent_relation].associations

              assoc =
                if associations.key?(meta[:combine_name])
                  associations[meta[:combine_name]]
                elsif associations.key?(name)
                  associations[name]
                end

              if assoc
                { assoc.target.key => assoc.target.dataset }
              else
                default_mapping
              end
            else
              default_mapping
            end

          if other.size > 0
            [mapping, [type, other]]
          else
            [mapping, type]
          end
        else
          registry[name][id] = container.commands[name][id]
          [name, id]
        end
      end

      # @api private
      def visit_header(node, *args)
        node.map { |n| visit(n, *args) }.compact
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
      # @param [Hash] meta Meta information from relation AST
      # @param [Symbol] parent_relation Optional parent relation identifier
      #
      # @return [ROM::Command]
      #
      # @api private
      def register_command(rel_name, type, meta, parent_relation = nil)
        relation = container.relations[rel_name]

        type.create_class(rel_name, type) do |klass|
          klass.result(meta.fetch(:combine_type, result))

          if meta[:combine_type]
            setup_associates(klass, relation, meta, parent_relation)
          end

          finalize_command_class(klass, relation)

          registry[rel_name][type] = klass.build(relation, input: relation.input_schema)
        end
      end

      # Return default result type
      #
      # @return [Symbol]
      #
      # @api private
      def result
        options.fetch(:result, :one)
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
            singular_name = Dry::Core::Inflector.singularize(parent_relation).to_sym
            singular_name if relation.associations.key?(singular_name)
          end

        if assoc_name
          klass.associates(assoc_name)
        else
          keys = meta[:keys].invert.to_a.flatten
          klass.associates(parent_relation, key: keys)
        end
      end

      # Setup a command class for a specific relation
      #
      # Every gateway may provide custom command extensions via
      # `Gateway#extend_command_class`. Furthermore, restrictible commands like
      # `Update` or `Delete` will be extended with relation view methods, so things
      # like `delete_user.by_id(1).call` becomes available.
      #
      # @param [Class] klass The command class
      # @param [Relation] relation The command relation
      #
      # @return [Class]
      #
      # @api private
      def finalize_command_class(klass, relation)
        # TODO: this is a copy-paste from rom's FinalizeCommands, we are missing
        #       an interface!
        gateway = container.gateways[relation.class.gateway]
        gateway.extend_command_class(klass, relation.dataset)

        klass.extend_for_relation(relation) if klass.restrictable

        plugins.each do |plugin|
          klass.use(plugin)
        end
      end
    end
  end
end
