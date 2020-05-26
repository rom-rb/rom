# frozen_string_literal: true

require 'rom/associations/abstract'

module ROM
  module Associations
    # Abstract one-to-many association
    #
    # @api public
    class OneToMany < Abstract
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
        definition.foreign_key || target.foreign_key(source.name)
      end

      # Associate child tuple with a parent
      #
      # @param [Hash] child The child tuple
      # @param [Hash] parent The parent tuple
      #
      # @return [Hash]
      #
      # @api private
      def associate(child, parent)
        pk, fk = join_key_map
        child.merge(fk => parent.fetch(pk))
      end

      protected

      # Return primary key on the source side
      #
      # @return [Symbol]
      #
      # @api protected
      def source_key
        source.schema.primary_key_name
      end

      # Return foreign key name on the target side
      #
      # @return [Symbol]
      #
      # @api protected
      def target_key
        foreign_key
      end

      memoize :foreign_key
    end
  end
end
