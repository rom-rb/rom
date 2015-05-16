require 'rom/relation/loaded'
require 'rom/relation/composite'
require 'rom/relation/materializable'

module ROM
  class Relation
    # Load a relation with its associations
    #
    # @example
    #   ROM.setup(:memory)
    #
    #   class Users < ROM::Relation[:memory]
    #   end
    #
    #   class Tasks < ROM::Relation[:memory]
    #     def for_users(users)
    #       restrict(user: users.map { |user| user[:name] })
    #     end
    #   end
    #
    #   rom = ROM.finalize.env
    #
    #   rom.relations[:users] << { name: 'Jane' }
    #   rom.relations[:tasks] << { user: 'Jane', title: 'Do something' }
    #
    #   rom.relation(:users).combine(rom.relation(:tasks).for_users)
    #
    # @api public
    class Graph
      include Materializable

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

      # @api private
      def initialize(root, nodes)
        @root = root
        @nodes = nodes
      end

      # Compose left-to-right data pipeline
      #
      # @example
      #   users_and_tasks = rom.relation(:users)
      #     .combine(rom.relation(:tasks).for_users)
      #
      #   users_and_tasks >> proc { |users, children|
      #     tasks = children.first
      #     # do stuff
      #   }
      #
      # @param [#call] other The right-side processing object
      #
      # @return [Relation::Composite]
      #
      # @api public
      def >>(other)
        Composite.new(self, other)
      end

      # Materialize this relation graph
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        left = root.call(*args)

        right =
          if left.count > 0
            nodes.map { |node| node.call(left) }
          else
            nodes.map { |node| Loaded.new(node, []) }
          end

        Loaded.new(self, [left, right])
      end
    end
  end
end
