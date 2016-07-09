require 'concurrent/map'

require 'rom/commands'
require 'rom/repository/command_proxy'

module ROM
  class Repository
    class CommandCompiler
      SUPPORTED_TYPES = %i[create update delete].freeze

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

      def self.cache
        @__cache__ ||= Concurrent::Map.new
      end

      def self.registry
        @__registry__ ||= Hash.new { |h, k| h[k] = {} }
      end

      attr_reader :type, :adapter, :container, :registry, :plugins

      def initialize(type, adapter, container, registry, plugins)
        @type = Commands.const_get(Inflector.classify(type))[adapter]
        @registry = registry
        @container = container
        @plugins = Array(plugins)
      end

      def visit(ast)
        name, node = ast
        __send__(:"visit_#{name}", node)
      end

      def visit_relation(node)
        name, meta, header = node
        other = visit(header)

        mapping =
          if meta[:combine_type] == :many
            name
          else
            { Inflector.singularize(name).to_sym => name }
          end

        register_command(name, type, meta)

        if other.size > 0
          [mapping, [type, other]]
        else
          [mapping, type]
        end
      end

      def visit_header(node)
        node.map { |n| visit(n) }.compact
      end

      def visit_attribute(node)
        nil
      end

      def register_command(name, type, meta)
        type.create_class(name, type) do |klass|
          if meta[:combine_type]
            klass.use(:associates)
            keys = meta[:keys].invert.to_a.flatten
            klass.associates(:parent, key: keys)
          end

          relation = container.relations[name]

          # TODO: this is a copy-paste from rom's FinalizeCommands, we are missing
          #       an interface!
          gateway = container.gateways[relation.class.gateway]
          gateway.extend_command_class(klass, relation.dataset)

          klass.extend_for_relation(relation) if type.restrictable

          result = meta.fetch(:combine_type, :one)

          plugins.each { |plugin| klass.use(plugin) }

          registry[name][type] = klass.build(relation, result: result)
        end
      end
    end
  end
end
