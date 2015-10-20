module ROM
  module Commands
    class Graph
      # Command graph builder DSL
      #
      # @api public
      class Builder
        # @api private
        DoubleRestrictionError = Class.new(StandardError) { def message; 'Attempting to call `#restrict` on the result of a previous `#restrict` call'; end }

        # @api private
        class Node
          # @api private
          Restriction = Struct.new(:parent_node, :relation, :proc)
          
          # @api private
          Command = Struct.new(:name, :relation, :key, :proc)

          # @api private
          def initialize(command)
            @command = command
            @nodes = []
          end

          # Return command ast from this union node
          #
          # @return [Array]
          #
          # @api private
          def to_ast
            if proc = @command.proc
              command = [@command.name => proc]
            else
              command = [@command.name]
            end
            
            key_relation_map = { @command.key => @command.relation }

            command << @nodes.map(&:to_ast) unless @nodes.empty?

            [key_relation_map, command]
          end

          # Tiny bit of syncactic sugar
          #
          # @api public
          def each(&block)
            block.call(self)
          end

          # Any missing method called on this is treated as a ROM command
          #
          # @api private
          def method_missing(*args, &block)
            command(*args, &block)
          end

          # @api private          
          def command(name, relation, restriction = nil, &block)
            proc = nil

            if restriction
              key = relation.is_a?(Hash) ? relation[:from] : nil
              relation = restriction.relation
              proc = restriction.proc
            else            
              if relation.is_a?(Hash)
                key, relation = relation.to_a.first
              end
            
              if relation.respond_to?(:relation)
                proc = relation.proc
                relation = relation.relation
              end
            end
            
            if key.nil?
              key = relation
            end
            
            node = Node.new(Command.new(name, relation, key, proc))
            block.call(node) if block
            @nodes << node

            node
          end
          
          # @api public
          def restrict(name, &block)
            RestrictionNode.new(self, name, block)
          end
        end
        
        # @api private
        class RestrictionNode
          attr_reader :relation, :proc

          def initialize(parent_node, relation, proc)
            @parent_node = parent_node
            @relation = relation
            @proc = proc
          end
          
          def restrict(name, &block)
            raise DoubleRestrictionError
          end
          
          def method_missing(*args, &block)
            args << self
            @parent_node.command(*args, &block)
          end
        end

        # @api private
        class RootNode < Node
          def initialize(container)
            @container = container
            @nodes = []
          end

          def to_ast
            if @nodes.size > 0
              @nodes.first.to_ast
            else
              []
            end
          end
          
          def command *args, &block
            super
            @container.command(to_ast)
          end
        end

        # @api public
        def initialize(container)
          @container = container
        end

        # @api private
        def method_missing(*args, &block)
          RootNode.new(@container).send(*args, &block)
        end
        
        def restrict(name, &block)
          RestrictionNode.new(RootNode.new(@container), name, block)
        end
      end
    end
  end
end
