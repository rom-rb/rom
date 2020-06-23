# frozen_string_literal: true

require "rom/types"
require "rom/associations/abstract"

module ROM
  module Associations
    # Abstract many-to-many association type
    #
    # @api public
    class ManyToMany < Abstract
      # @!attribute [r] join_relation
      #   @return [Relation] Intermediate join relation
      attr_reader :join_relation

      # @api private
      def initialize(*)
        super
        @join_relation = relations[through]
      end
      ruby2_keywords(:initialize) if respond_to?(:ruby2_keywords, true)

      # Adapters should implement this method
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
        definition.foreign_key || join_relation.foreign_key(source.name)
      end

      # Return join-relation name
      #
      # @return [Symbol]
      #
      # @api public
      def through
        definition.through
      end

      # Return parent's relation combine keys
      #
      # @return [Hash<Symbol=>Symbol>]
      #
      # @api private
      def parent_combine_keys
        target.associations[source.name].combine_keys.to_a.flatten(1)
      end

      # Associate child tuples with the provided parent
      #
      # @param [Array<Hash>] children An array with child tuples
      # @param [Array,Hash] parent An array with parent tuples or a single tuple
      #
      # @return [Array<Hash>]
      #
      # @api private
      def associate(children, parent)
        ((spk, sfk), (tfk, tpk)) = join_key_map

        case parent
        when Array
          parent.map { |p| associate(children, p) }.flatten(1)
        else
          children.map { |tuple|
            {sfk => tuple.fetch(spk), tfk => parent.fetch(tpk)}
          }
        end
      end

      protected

      # Primary key name on the source side
      #
      # @return [Symbol]
      #
      # @api protected
      def source_key
        source.primary_key
      end

      # Foreign key name on the target side
      #
      # @return [Symbol]
      #
      # @api protected
      def target_key
        foreign_key
      end

      # Return association for many-to-many-through
      #
      # @return [Association]
      #
      # @api protected
      def join_assoc
        if join_relation.associations.key?(through.assoc_name)
          join_relation.associations[through.assoc_name]
        else
          join_relation.associations[through.target]
        end
      end

      # Return a [pk, fk] mapping for source/target relations
      #
      # @return [Array<Symbol>]
      #
      # @api protected
      def join_key_map
        left = super
        right = join_assoc.join_key_map

        [left, right]
      end

      memoize :foreign_key, :join_assoc, :join_key_map
    end
  end
end
