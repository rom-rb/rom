# frozen_string_literal: true

require "rom/associations/abstract"

module ROM
  module Associations
    # Abstract many-to-one association type
    #
    # @api public
    class ManyToOne < Abstract
      # Adapters must implement this method
      #
      # @abstract
      #
      # @api public
      def call(*)
        raise NotImplementedError
      end

      # Return configured or inferred FK name
      #
      # @return [Symbol]
      #
      # @api public
      def foreign_key
        definition.foreign_key || source.foreign_key(target.name)
      end

      # Associate child with a parent
      #
      # @param [Hash] child The child tuple
      # @param [Hash] parent The parent tuple
      #
      # @return [Hash]
      #
      # @api private
      def associate(child, parent)
        fk, pk = join_key_map
        child.merge(fk => parent.fetch(pk))
      end

      protected

      # Return foreign key on the source side
      #
      # @return [Symbol]
      #
      # @api protected
      def source_key
        foreign_key
      end

      # Return primary key on the target side
      #
      # @return [Symbol]
      #
      # @api protected
      def target_key
        target.schema.primary_key_name
      end

      memoize :foreign_key
    end
  end
end
