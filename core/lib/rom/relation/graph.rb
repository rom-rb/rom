require 'rom/relation/loaded'
require 'rom/relation/composite'
require 'rom/relation/materializable'
require 'rom/relation/commands'
require 'rom/pipeline'

module ROM
  class Relation
    # Compose relations using join-keys
    #
    # @example
    #   class Users < ROM::Relation[:memory]
    #   end
    #
    #   class Tasks < ROM::Relation[:memory]
    #     def for_users(users)
    #       restrict(user: users.map { |user| user[:name] })
    #     end
    #   end
    #
    #   rom.relations[:users] << { name: 'Jane' }
    #   rom.relations[:tasks] << { user: 'Jane', title: 'Do something' }
    #
    #   rom.relation(:users).combine(rom.relation(:tasks).for_users)
    #
    # @api public
    class Graph
      include Materializable
      include Commands
      include Pipeline
      include Pipeline::Proxy

      # Root aka parent relation
      #
      # @return [Relation::Lazy]
      #
      # @api private
      attr_reader :root

      # Child relation nodes
      #
      # @return [Array<Relation::Lazy>]
      #
      # @api private
      attr_reader :nodes

      alias_method :left, :root
      alias_method :right, :nodes

      # @api private
      def self.build(root, nodes)
        if nodes.any? { |node| node.instance_of?(Composite) }
          raise UnsupportedRelationError,
            "Combining with composite relations is not supported"
        else
          new(root, nodes)
        end
      end

      # @api private
      def initialize(root, nodes)
        @root = root
        @nodes = nodes
      end

      # @api public
      def with_nodes(nodes)
        self.class.new(root, nodes)
      end

      # Return if this is a graph relation
      #
      # @return [true]
      #
      # @api private
      def graph?
        true
      end

      # Combine this graph with more nodes
      #
      # @param [Array<Relation::Lazy>]
      #
      # @return [Graph]
      #
      # @api public
      def graph(*others)
        self.class.new(root, nodes + others)
      end

      # @api public
      def combine(*args)
        self.class.new(root, nodes + root.combine(*args).nodes)
      end

      # Materialize this relation graph
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        left = root.with(auto_struct: false).call(*args)

        right =
          if left.empty?
            nodes.map { |node| Loaded.new(node, EMPTY_ARRAY) }
          else
            nodes.map { |node| node.call(left) }
          end

        if auto_map?
          Loaded.new(self, mapper.([left, right]))
        else
          Loaded.new(self, [left, right])
        end
      end

      # @api public
      def map_with(*args)
        self.class.new(root.map_with(*args), nodes)
      end
      alias_method :as, :map_with

      # Return a new graph with adjusted node returned from a block
      #
      # @example with a node identifier
      #   aggregate(:tasks).node(:tasks) { |tasks| tasks.prioritized }
      #
      # @example with a nested path
      #   aggregate(tasks: :tags).node(tasks: :tags) { |tags| tags.where(name: 'red') }
      #
      # @param [Symbol] name The node relation name
      #
      # @yieldparam [RelationProxy] The relation node
      # @yieldreturn [RelationProxy] The new relation node
      #
      # @return [RelationProxy]
      #
      # @api public
      def node(name, &block)
        if name.is_a?(Symbol) && !nodes.map { |n| n.name.key }.include?(name)
          raise ArgumentError, "#{name.inspect} is not a valid aggregate node name"
        end

        new_nodes = nodes.map { |node|
          case name
          when Symbol
            name == node.name.key ? yield(node) : node
          when Hash
            other, *rest = name.flatten(1)
            if other == node.name.key
              nodes.detect { |n| n.name.key == other }.node(*rest, &block)
            else
              node
            end
          else
            node
          end
        }

        with_nodes(new_nodes)
      end

      # @api public
      def to_ast
        [:relation, [name.to_sym, attr_ast + node_ast, meta_ast]]
      end

      # @api private
      def node_ast
        nodes.map(&:to_ast)
      end

      # @api private
      def mapper
        mappers[to_ast]
      end

      private

      # @api private
      def decorate?(other)
        super || other.is_a?(Composite) || other.is_a?(Curried)
      end

      # @api private
      def composite_class
        Relation::Composite
      end
    end
  end
end
