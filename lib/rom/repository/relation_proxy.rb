require 'rom/support/options'
require 'rom/relation/materializable'

require 'rom/repository/relation_proxy/combine'
require 'rom/repository/relation_proxy/wrap'

module ROM
  class Repository
    # RelationProxy decorates a relation and automatically generate mappers that
    # will map raw tuples into structs
    #
    # @api public
    class RelationProxy
      include Options
      include Relation::Materializable

      include RelationProxy::Combine
      include RelationProxy::Wrap

      option :name, reader: true, type: Symbol
      option :mappers, reader: true, default: proc { MapperBuilder.new }
      option :meta, reader: true, type: Hash, default: EMPTY_HASH
      option :registry, type: Hash, default: EMPTY_HASH, reader: true

      # @attr_reader [ROM::Relation::Lazy] relation Decorated relation
      attr_reader :relation

      # @api private
      def initialize(relation, options = {})
        super
        @relation = relation
      end

      # Materialize wrapped relation and send it through a mapper
      #
      # For performance reasons a combined relation will skip mapping since
      # we only care about extracting key values for combining
      #
      # @api public
      def call(*args)
        ((combine? || composite?) ? relation : (relation >> mapper)).call(*args)
      end

      # Map this relation with other mappers too
      #
      # @api public
      def map_with(*names)
        if names.size == 1 && names[0].is_a?(Class)
          with(meta: meta.merge(model: names[0]))
        else
          names.reduce(self) { |a, e| a >> relation.mappers[e] }
        end
      end
      alias_method :as, :map_with

      # Return AST for this relation
      #
      # @return [Array]
      #
      # @api private
      def to_ast
        attr_ast = attributes.map { |name| [:attribute, name] }

        node_ast = nodes.map(&:to_ast)
        wrap_ast = wraps.map(&:to_ast)

        wrap_attrs = wraps.flat_map { |wrap|
          wrap.attributes.map { |c| [:attribute, :"#{wrap.base_name}_#{c}"] }
        }

        meta = options[:meta].merge(base_name: relation.base_name)
        meta.delete(:wraps)

        header = (attr_ast - wrap_attrs) + node_ast + wrap_ast

        [:relation, [name, meta, [:header, header]]]
      end

      # Infer a mapper for the relation
      #
      # @return [ROM::Mapper]
      #
      # @api private
      def mapper
        mappers[to_ast]
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      # Return new instance with new options
      #
      # @return [RelationProxy]
      #
      # @api private
      def with(new_options)
        __new__(relation, new_options)
      end

      # Return if this relation is combined
      #
      # @return [Boolean]
      #
      # @api private
      def combine?
        meta[:combine_type]
      end

      # Return if this relation is a composite
      #
      # @return [Boolean]
      #
      # @api private
      def composite?
        relation.is_a?(Relation::Composite)
      end

      # Return meta info for this relation
      #
      # @return [Hash]
      #
      # @api private
      def meta
        options[:meta]
      end

      # Return all nodes that this relation combines
      #
      # @return [Array<RelationProxy>]
      #
      # @api private
      def nodes
        relation.respond_to?(:nodes) ? relation.nodes : []
      end

      # @api private
      def adapter
        relation.class.adapter
      end

      private

      # Return a new instance with another relation and options
      #
      # @return [RelationProxy]
      #
      # @api private
      def __new__(relation, new_options = {})
        self.class.new(relation, options.merge(new_options))
      end

      # Return all nodes that this relation wraps
      #
      # @return [Array<RelationProxy>]
      #
      # @api private
      def wraps
        meta.fetch(:wraps, [])
      end

      # Forward to relation and wrap it with proxy if response was a relation too
      #
      # TODO: this will be simplified once ROM::Relation has lazy-features built-in
      #       and ROM::Lazy is gone
      #
      # @api private
      def method_missing(meth, *args, &block)
        if relation.respond_to?(meth)
          result = relation.__send__(meth, *args, &block)

          if result.kind_of?(Relation::Materializable) && !result.is_a?(Relation::Loaded)
            __new__(result)
          else
            result
          end
        else
          super
        end
      end

      # @api private
      def respond_to_missing?(meth, _include_private = false)
        relation.respond_to?(meth) || super
      end
    end
  end
end
