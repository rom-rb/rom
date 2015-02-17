module ROM
  module Memory
    # Relation subclass for memory adapter
    #
    # @example
    #   class Users < ROM::Relation[:memory]
    #   end
    #
    # @api public
    class Relation < ROM::Relation
      include Enumerable

      forward :join, :project, :restrict, :order

      # Insert tuples into the relation
      #
      # @example
      #   users.insert(name: 'Jane')
      #
      # @return [Relation]
      #
      # @api public
      def insert(*args)
        dataset.insert(*args)
        self
      end
      alias_method :<<, :insert

      # Delete tuples from the relation
      #
      # @example
      #   users.insert(name: 'Jane')
      #   users.delete(name: 'Jane')
      #
      # @return [Relation]
      #
      # @api public
      def delete(*args)
        dataset.delete(*args)
        self
      end
    end
  end
end
