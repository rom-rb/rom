module ROM
  module Commands
    class Graph
      class DSL
        attr_reader :container

        class Node
          class Composite < Pipeline::Composite
            def to_ast
              l_ast = left.to_ast
              r_ast = right.to_ast
              l_ast[1] << r_ast
              l_ast
            end
          end

          attr_reader :name, :relation, :options, :cmd_block

          def initialize(name, relation, options = {}, &cmd_block)
            @name = name
            @relation = relation
            @options = options
            @cmd_block = cmd_block
          end

          def >>(other)
            Node::Composite.new(self, other)
          end

          def to_ast
            [from, identifier]
          end

          def from
            { options.fetch(:from, relation) => relation }
          end

          def identifier
            if cmd_block
              [{ name => cmd_block }]
            else
              [name]
            end
          end
        end

        def initialize(container)
          @container = container
        end

        def call(&block)
          node = instance_exec(&block)
          node.to_ast
        end

        def method_missing(name, *args, &block)
          Node.new(name, *args, &block)
        end
      end
    end
  end
end
