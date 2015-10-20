module ROM
  module Commands
    class Graph
      # Command graph builder DSL
      #
      # @api public
      class Builder
        # @api private
        DoubleRestrictionError = Class.new(StandardError) { def message; 'Attempting to call `#restrict` on the result of a previous `#restrict` call'; end }
        UnspecifiedRelationError = Class.new(StandardError) { def message; 'Command methods require a relation to be specified, either as part of `#restrict` call or as an argument'; end }

        # @api private
        class Node
          # @api private
          Restriction = Struct.new(:relation, :proc)
          
          # @api private
          Command = Struct.new(:name, :relation, :key, :proc)

          attr_reader :command

          # @api private
          def initialize(parent_node = nil, command = nil)
            @parent_node = parent_node
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
          def command(name, relation = nil, key = nil, proc = nil, &block)
            if relation.is_a?(Hash)
              key, relation = relation.to_a.first
            end
          
            if relation.is_a?(RestrictionNode)
              RestrictionNode.new(self, relation.restriction).command(name, from: key, &block)
            else
              if key.nil?
                key = relation
              end

              raise UnspecifiedRelationError if relation.nil?
            
              command = Command.new(name, relation, key, proc)
              Node.new(self, command).tap do |node|
                block.call(node) if block
                @nodes << node
              end
            end
          end
          
          # @api public
          def restrict(name, &block)
            RestrictionNode.new(self, Restriction.new(name, block))
          end
        end

        # @api private
        class RestrictionNode < Node
          attr_reader :restriction
          
          def initialize parent_node, restriction
            @parent_node = parent_node
            @restriction = restriction
            @nodes = []
          end
          
          def command(name, relation = nil, &block)
            key = relation.is_a?(Hash) ? relation[:from] : nil
            relation = @restriction.relation
            proc = @restriction.proc

            @parent_node.command(name, relation, key || relation, proc, &block)
          end

          def restrict(name, &block)
            raise DoubleRestrictionError
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
        end
        
        # @api private
        class BuilderNode < RootNode
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
          BuilderNode.new(@container).send(*args, &block)
        end
      end
    end
  end
end
