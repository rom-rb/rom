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
          Restriction = Struct.new(:relation, :proc)
          
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
          def method_missing(name, relation, &block)
            proc = nil
            
            if relation.is_a?(Hash)
              key, relation = relation.to_a.first
            end
            
            if relation.respond_to?(:relation)
              proc = relation.proc
              relation = relation.relation
            end
            
            if key.nil?
              key = relation
            end
            
            node = Node.new(Command.new(name, relation, key, proc))
            block.call(node) if block
            @nodes << node

            node
          end
          
          def restrict(name, &block)
            Restriction.new(name, block)
          end
        end

        # @api private
        class RootNode < Node
          def initialize
            @nodes = []
          end

          def to_ast
            if @nodes.size > 0
              @nodes.first.to_ast
            else
              []
            end
          end
        end

        # @api public
        def initialize(&block)
          @callback = block
        end

        # @api public
        def to_ast
          @node ? @node.to_ast : []
        end

        # @api private
        def method_missing(name, *attrs, &block)
          @node = RootNode.new
          @node.send(name, *attrs, &block)

          if @callback
            @callback.call(self)
          else
            self
          end
        end
        
        def restrict(name, &block)
          Node::Restriction.new(name, block)
        end
      end
    end
  end
end
