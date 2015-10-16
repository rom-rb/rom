module ROM
  module Commands
    class Graph
      # Command graph builder DSL
      #
      # @api public
      class Builder
        # @api private
        class Node
          # @api private
          Command = Struct.new(:name, :relation, :key)

          # @api private
          def initialize command
            @command = command
            @nodes = []
          end

          # Return command ast from this union node
          #
          # @return [Array]
          #
          # @api private
          def to_ast
            command = [@command.name]
            key_relation_map = {@command.key => @command.relation}

            unless @nodes.empty?
              command << @nodes.map(&:to_ast)
            end
    
            [key_relation_map, command]
          end
          
          # Tiny bit of syncactic sugar
          #
          # @api public
          def each &block
            block.call(self)
          end
          
          # Any missing method called on this is treated as a ROM command
          #
          # @api private
          def method_missing name, relation, &block
            if relation.is_a? Hash
              relation, key = relation.to_a.first
            else
              relation, key = relation, relation
            end

            node = Node.new(Command.new(name, relation, key))
            block.call(node) if block
            @nodes << node
    
            node
          end
        end
        
        # @api private
        class RootNode < Node
          def initialize
            @nodes = []
          end
  
          def to_ast
            @nodes.first.to_ast rescue []
          end
        end
        
        # @api public
        def initialize &block
          @callback = block
        end
        
        # @api public
        def to_ast
          @node ? @node.to_ast : []
        end
        
        # @api private
        def method_missing name, *attrs, &block
          @node = RootNode.new
          @node.send(name, *attrs, &block)

          if @callback
            @callback.call(self)
          else
            self
          end
        end
      end
    end
  end
end
