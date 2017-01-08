require 'rom/memory/types'
require 'rom/memory/schema'

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
      include Memory

      adapter :memory
      schema_class Memory::Schema

      forward :take, :join, :restrict, :order

      # Project a relation with provided attribute names
      #
      # @param [*Array] names A list with attribute names
      #
      # @return [Memory::Relation]
      #
      # @api public
      def project(*names)
        schema.project(*names).(self)
      end

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
