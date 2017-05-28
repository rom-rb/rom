require 'dry/core/deprecations'

require 'rom/relation/loaded'
require 'rom/relation/composite'
require 'rom/relation/materializable'
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
      extend Dry::Core::Deprecations[:rom]

      include Materializable
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
      deprecate :combine, :graph

      # Materialize this relation graph
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        left = root.call(*args)

        right =
          if left.empty?
            nodes.map { |node| Loaded.new(node, EMPTY_ARRAY) }
          else
            nodes.map { |node| node.call(left) }
          end

        Loaded.new(self, [left, right])
      end

      private

      # @api private
      def decorate?(other)
        super || other.is_a?(Curried)
      end

      # @api private
      def composite_class
        Relation::Composite
      end
    end
  end
end
