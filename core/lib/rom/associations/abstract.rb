# frozen_string_literal: true

require 'rom/initializer'
require 'rom/support/memoizable'

module ROM
  module Associations
    # Abstract association class
    #
    # @api public
    class Abstract
      extend Initializer

      include Memoizable
      include Dry::Equalizer(:definition, :source, :target)

      # @!attribute [r] definition
      #   @return [ROM::Associations::Definition] Association configuration object
      param :definition

      # @!attribute [r] relations
      #   @return [ROM::RelationRegistry] Relation registry
      option :relations, reader: true

      # @!attribute [r] source
      #   @return [ROM::SQL::Relation] the source relation
      option :source, reader: true

      # @!attribute [r] target
      #   @return [ROM::SQL::Relation::Name] the target relation
      option :target, reader: true

      # Create an association object
      #
      # @param [Definition] definition The association definition object
      # @param [RelationRegistry] relations The relation registry
      #
      # @api public
      def self.new(definition, relations)
        super(
          definition,
          relations: relations,
          source: relations[definition.source.relation],
          target: relations[definition.target.relation]
        )
      end

      # Return if an association has an alias
      #
      # @return [Boolean]
      #
      # @api public
      def aliased?
        definition.aliased?
      end

      # Return association alias
      #
      # @return [Symbol]
      #
      # @api public
      def as
        definition.as
      end

      # Return association canonical name
      #
      # @return [Symbol]
      #
      # @api public
      def name
        definition.name
      end

      # Return the name of a custom relation view that should be use to
      # extend or override default association view
      #
      # @return [Symbol]
      #
      # @api public
      def view
        definition.view
      end

      # Return association foreign key name
      #
      # @return [Symbol]
      #
      # @api public
      def foreign_key
        definition.foreign_key
      end

      # Return result type
      #
      # This can be either :one or :many
      #
      # @return [Symbol]
      #
      # @api public
      def result
        definition.result
      end

      # Return if a custom view should override default association view
      #
      # @return [Boolean]
      #
      # @api public
      def override?
        definition.override
      end

      # Return the name of a key in tuples under which loaded association data are returned
      #
      # @return [Symbol]
      #
      # @api public
      def key
        as || name
      end

      # Applies custom view to the default association view
      #
      # @return [Relation]
      #
      # @api protected
      def apply_view(schema, relation)
        view_rel = relation.public_send(view)
        schema.merge(view_rel.schema).uniq(&:key).(view_rel)
      end

      # Return combine keys hash
      #
      # Combine keys are used for merging associated data together, typically these
      # are the same as fk<=>pk mapping
      #
      # @return [Hash<Symbol=>Symbol>]
      #
      # @api public
      def combine_keys
        definition.combine_keys || { source_key => target_key }
      end

      # Return names of source PKs and target FKs
      #
      # @return [Array<Symbol>]
      #
      # @api private
      def join_key_map
        join_keys.to_a.flatten(1).map(&:key)
      end

      # Return target relation configured as a combine node
      #
      # @return [Relation]
      #
      # @api private
      def node
        target.with(
          name: target.name.as(key),
          meta: { keys: combine_keys, combine_type: result, combine_name: key }
        )
      end

      # Return target relation as a wrap node
      #
      # @return [Relation]
      #
      # @api private
      def wrap
        target.with(
          name: target.name.as(key),
          schema: target.schema.wrap,
          meta: { wrap: true, combine_name: key }
        )
      end

      # Prepare association's target relation for composition
      #
      # @return [Relation]
      #
      # @api private
      def prepare(target)
        if override?
          target.public_send(view)
        else
          call(target: target)
        end
      end

      # Return if this association's source relation is the same as the target
      #
      # @return [Boolean]
      #
      # @api private
      def self_ref?
        source.name.dataset == target.name.dataset
      end

      memoize :combine_keys, :join_key_map
    end
  end
end
