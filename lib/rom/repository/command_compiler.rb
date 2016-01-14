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
        type, node, *other = ast

        if other.any?
          __send__(:"visit_#{type}", node, other)
        else
          __send__(:"visit_#{type}", node)
        end
      end

      def visit_relation(name, node)
        header, opts = node
        base_name = opts[:base_name]
        other = visit(header)

        mapping =
          if opts[:combine_type] == :many
            base_name
          else
            { Inflector.singularize(name).to_sym => base_name }
          end

        register_command(base_name, type, opts)

        [mapping, [type].concat(other)]
      end

      def visit_header(node)
        node.map { |n| visit(n) }.compact
      end

      def visit_attribute(node)
        nil
      end

      def register_command(name, type, opts)
        klass = ClassBuilder.new(name: "Create[#{name}]", parent: type).call

        if opts[:combine_type]
          klass.use(:associates)
          klass.associates(:parent, key: opts[:keys].invert.to_a.flatten)
          klass.result opts[:combine_type]
        end

        registry[name][type] = klass.build(container.relations[name], result: :one)
      end
    end
  end
end
