module ROM
  module Commands
    class Graph
      # Command graph builder DSL
      #
      # @api public
      class Builder
        # @api private
        UnspecifiedRelationError = Class.new(StandardError)
        DoubleRestrictionError = Class.new(StandardError)

        # @api private
        class Node
          # @api private
          Restriction = Struct.new(:relation, :proc)

          # @api private
          Command = Struct.new(:name, :relation, :key, :proc)

          # @api private
          def initialize
            @nodes = []
          end

          # @api public
          def to_ast
            []
          end

          # Any missing method called on this is treated as a ROM command
          #
          # @api private
          def method_missing(*args, &block)
            command(*args, &block)
          end

          # @api public
          def command(name, relation = nil, key = nil, proc = nil, &block)
            if relation.is_a?(Hash)
              key, relation = relation.to_a.first
            end

            raise UnspecifiedRelationError if relation.nil?

            if relation.is_a?(RestrictionNode)
              RestrictionNode.new(relation.restriction).command(name, from: key, &block)
            else
              key ||= relation

              command = Command.new(name, relation, key, proc)
              node = CommandNode.new(command)
              block.call(node) if block
              node
            end
          end

          # @api public
          def restrict(name, &block)
            RestrictionNode.new(Restriction.new(name, block), self)
          end
        end

        # @api private
        class CommandNode < Node
          # @api private
          def initialize(command = nil)
            @command = command
            @nodes = []
          end

          # Tiny bit of synctactic sugar
          #
          # @api public
          def each(&block)
            block.call(self)
          end

          # Return command ast from this union node
          #
          # @return [Array]
          #
          # @api private
          def to_ast
            if @command.proc
              command = [@command.name => @command.proc]
            else
              command = [@command.name]
            end

            key_relation_map = { @command.key => @command.relation }

            command << @nodes.map(&:to_ast) unless @nodes.empty?

            [key_relation_map, command]
          end

          # @api public
          def command(*args, &block)
            node = super
            @nodes << node
            node
          end
        end

        # @api private
        class RestrictionNode < Node
          attr_reader :restriction

          def initialize(restriction, parent_node = nil)
            super()
            @restriction = restriction
            @parent_node = parent_node
          end

          # @api public
          def command(name, options = {}, &block)
            relation = @restriction.relation
            key = options[:from] || relation
            proc = @restriction.proc

            if @parent_node
              @parent_node.command(name, relation, key, proc, &block)
            else
              super(name, relation, key, proc, &block)
            end
          end

          # @api private
          def restrict(*args, &block)
            raise DoubleRestrictionError
          end
        end

        # @api private
        class RootNode < Node
          def to_ast
            if @nodes.size > 0
              @nodes.first.to_ast
            else
              []
            end
          end

          def command(*args, &block)
            node = super
            @nodes << node
            node
          end
        end

        # @api private
        class BuilderNode < RootNode
          def initialize(container)
            super()
            @container = container
          end

          def command(*args, &block)
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
