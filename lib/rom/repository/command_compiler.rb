require 'concurrent/map'

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
      SUPPORTED_TYPES = %i[create update delete].freeze

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
      # @param [ROM::Container] container where relations are stored
      # @param [Symbol] type of command
      # @param [Symbol] adapter identifier
      # @param [Array] AST representation of a relation
      # @param [Array<Symbol>] a list of optional command plugins that should be used
      #
      # @return [Command, CommandProxy]
      #
      # @api private
      def self.[](*args)
        cache.fetch_or_store(args.hash) do
          container, type, adapter, ast, plugins = args

          unless SUPPORTED_TYPES.include?(type)
            raise ArgumentError, "#{type.inspect} is not a supported command type"
          end

          graph_opts = new(type, adapter, container, registry, plugins).visit(ast)

          command = ROM::Commands::Graph.build(registry, graph_opts)

          if command.graph?
            CommandProxy.new(command)
          else
            command.unwrap
          end
        end
      end

      # @api private
      def self.cache
        @__cache__ ||= Concurrent::Map.new
      end

      # @api private
      def self.registry
        @__registry__ ||= Hash.new { |h, k| h[k] = {} }
      end

      # @attr [Symbol] type of relation
      attr_reader :type

      # @attr [Symbol] adapter identifier ie :sql or :http
      attr_reader :adapter

      # @attr [ROM::Container] rom container with relations and gateways
      attr_reader :container

      # @attr [Hash] local registry where commands will be stored during compilation
      attr_reader :registry

      # @attr [Array<Symbol>] a list of optional plugins that will be enabled for
      #                       commands
      attr_reader :plugins

      # @api private
      def initialize(type, adapter, container, registry, plugins)
        @type = Commands.const_get(Inflector.classify(type))[adapter]
        @registry = registry
        @container = container
        @plugins = Array(plugins)
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

        mapping =
          if meta[:combine_type] == :many
            name
          else
            { Inflector.singularize(name).to_sym => name }
          end

        register_command(name, type, meta, parent_relation)

        if other.size > 0
          [mapping, [type, other]]
        else
          [mapping, type]
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
          klass.result(meta.fetch(:combine_type, :one))

          if meta[:combine_type]
            setup_associates(klass, relation, meta, parent_relation)
          end

          finalize_command_class(klass, relation)

          registry[rel_name][type] = klass.build(relation)
        end
      end

      # Sets up `associates` plugin for a given command class and relation
      #
      # @param [Class] klass The command class
      # @param [Relation] relation The relation for the command
      #
      # @api private
      def setup_associates(klass, relation, meta, parent_relation)
        klass.use(:associates)

        assoc_name =
          if klass.result == :many
            Inflector.singularize(parent_relation).to_sym
          else
            parent_relation
          end

        relation.associations.try(assoc_name) do |assoc|
          klass.associates(assoc.name)
        end or (
          keys = meta[:keys].invert.to_a.flatten
          klass.associates(parent_relation, key: keys)
        )
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

        plugins.each { |plugin| klass.use(plugin) }
      end
    end
  end
end
