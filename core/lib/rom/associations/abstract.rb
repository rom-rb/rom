require 'dry/core/constants'
require 'dry/core/class_attributes'

require 'rom/types'
require 'rom/initializer'

module ROM
  module Associations
    # Abstract association class
    #
    # @api public
    class Abstract
      extend Initializer

      include Dry::Core::Constants
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

      # @api public
      def self.new(definition, relations)
        super(
          definition,
          relations: relations,
          source: relations[definition.source.relation],
          target: relations[definition.target.relation]
        )
      end

      # @api public
      def view
        definition.view
      end

      # @api public
      def name
        definition.name
      end

      # @api public
      def foreign_key
        definition.foreign_key
      end

      # @api public
      def result
        definition.result
      end

      # @api public
      def join(type, source = self.source, target = self.target)
        source.__send__(type, target.name.dataset, join_keys).qualified
      end

      # @api protected
      def apply_view(schema, relation)
        view_rel = relation.public_send(view)
        schema.merge(view_rel.schema.qualified).uniq(&:to_sql_name).(view_rel)
      end

      # @api public
      def combine_keys
        Hash[*with_keys]
      end

      # @api private
      def join_key_map
        join_keys.to_a.flatten.map(&:key)
      end

      # @api private
      def node
        # TODO: remove `for_combine` in favor of a generic `Relation#preload`
        target.with(
          name: target.name.as(name.to_sym),
          meta: { keys: combine_keys, combine_type: result, combine_name: name.to_sym }
        ).for_combine(self)
      end

      # @api private
      def wrap
        target.with(
          name: target.name.as(name.to_sym),
          schema: target.schema.wrap,
          meta: { wrap: true, combine_name: name.to_sym }
        )
      end

      # @api private
      def self_ref?
        source.name.dataset == target.name.dataset
      end
    end
  end
end
