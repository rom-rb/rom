# frozen_string_literal: true

require "rom/relation"
require "rom/memory/types"
require "rom/memory/schema"

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
      schema_dsl Schema::DSL

      # @!method take(amount)
      #   @param (see Dataset#take)
      #   @return [Relation]
      #   @see Dataset#take
      #
      # @!method join(*args)
      #   @param (see Dataset#take)
      #   @return [Relation]
      #   @see Dataset#join
      #
      # @!method restrict(criteria = nil)
      #   @param (see Dataset#restrict)
      #   @return [Relation]
      #   @see Dataset#restrict
      #
      # @!method order(*fields)
      #   @param (see Dataset#order)
      #   @return [Relation]
      #   @see Dataset#order
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

      # Rename attributes in a relation
      #
      # @api public
      def rename(mapping)
        schema.rename(mapping).(self)
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
