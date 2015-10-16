module ROM
  module Commands
    class Graph
      # Command graph builder DSL
      #
      # @api public
      class DSL
        class Node
          # Two-command pipe
          #
          # @api private
          class Composite < Pipeline::Composite
            def to_ast
              l_ast = left.to_ast
              r_ast = right.to_ast
              l_ast[1] << r_ast
              l_ast
            end

            # Create a union of this and other node
            #
            # @return [Union]
            #
            # @api public
            def +(other)
              Union.new(self, other)
            end
          end

          # A union of two command nodes
          class Union
            # @attr_reader [Node,Composite]
            attr_reader :left

            # @attr_reader [Node,Composite]
            attr_reader :right

            # @api private
            def initialize(left, right)
              @left = left
              @right = right
            end

            # Return command ast from this union node
            #
            # @return [Array]
            #
            # @api private
            def to_ast
              [left.to_ast, right.to_ast]
            end
          end

          # @attr_reader [Symbol] name of the key in the command input
          attr_reader :name

          # @attr_reader [Symbol] relation name that will handle input under specific key
          attr_reader :relation

          # @attr_reader [Hash] options passed to DSL method
          attr_reader :options

          # @attr_reader [Proc] command proc that will be set for a lazy command
          attr_reader :cmd_block

          # @api private
          def initialize(name, relation, options = {}, &cmd_block)
            @name = name
            @relation = relation
            @options = options
            @cmd_block = cmd_block
          end

          # Compose a pipeline for lazy commands
          #
          # @param [Node] other
          #
          # @return [Composite]
          #
          # @api public
          def >>(other)
            Composite.new(self, other)
          end

          # @api public
          def +(other)
            Union.new(self, other)
          end

          # Return command graph ast node
          #
          # @return [Array]
          #
          # @api private
          def to_ast
            [from, identifier]
          end

          private

          # Create input name => relation name mapping for ast node
          #
          # @api private
          def from
            { options.fetch(:from, relation) => relation }
          end

          # Create command identifier for ast node
          #
          # @api private
          def identifier
            if cmd_block
              [{ name => cmd_block }]
            else
              [name]
            end
          end
        end

        # Get command graph ast by evaluating provided block
        #
        # @return [Array]
        #
        # @api public
        def call(&block)
          node = instance_exec(&block)
          node.to_ast
        end

        private

        # @api private
        def method_missing(name, *args, &block)
          Node.new(name, *args, &block)
        end
      end
    end
  end
end
