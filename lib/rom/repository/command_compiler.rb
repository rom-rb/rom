module ROM
  class Repository
    class CommandCompiler
      def self.[](container, type, adapter, ast)
        registry = Hash.new { |h, k| h[k] = {} }
        command_opts = new(type, adapter, container, registry).visit(ast)

        ROM::Commands::Graph.build(registry, command_opts)
      end

      attr_reader :type, :adapter, :container, :registry

      def initialize(type, adapter, container, registry)
        @type = Commands.const_get(Inflector.classify(type))[adapter]
        @registry = registry
        @container = container
      end

      def visit(ast)
        name, node = ast
        __send__(:"visit_#{name}", node)
      end

      def visit_relation(node)
        name, meta, header = node
        base_name = meta[:base_name]
        other = visit(header)

        mapping =
          if meta[:combine_type] == :many
            base_name
          else
            { Inflector.singularize(name).to_sym => base_name }
          end

        register_command(base_name, type, meta)

        [mapping, [type].concat(other)]
      end

      def visit_header(node)
        node.map { |n| visit(n) }.compact
      end

      def visit_attribute(node)
        nil
      end

      def register_command(name, type, meta)
        klass = ClassBuilder.new(name: "Create[#{name}]", parent: type).call

        if meta[:combine_type]
          klass.use(:associates)
          klass.associates(:parent, key: meta[:keys].invert.to_a.flatten)
          klass.result meta[:combine_type]
        end

        registry[name][type] = klass.build(container.relations[name], result: :one)
      end
    end
  end
end
