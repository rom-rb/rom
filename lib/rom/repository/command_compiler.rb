module ROM
  class Repository
    class CommandCompiler
      def self.[](registry, type, adapter, ast)
        command_opts = new(type).visit(ast)
        ROM::Commands::Graph.build(registry, command_opts)
      end

      attr_reader :type

      def initialize(type)
        @type = type
      end

      def visit(ast)
        type, name, *node = ast
        __send__(:"visit_#{type}", name, node)
      end

      def visit_relation(name, node)
        _, opts = node
        [{ Inflector.singularize(name).to_sym => opts[:base_name] }, [type]]
      end
    end
  end
end
