require 'rom/support/options'
require 'rom/relation/materializable'

require 'rom/repository/relation_proxy/combine'
require 'rom/repository/relation_proxy/wrap'

module ROM
  class Repository
    # RelationProxy decorates a relation and automatically generates mappers that
    # will map raw tuples into rom structs
    #
    # Relation proxies are being registered within repositories so typically there's
    # no need to instantiate them manually.
    #
    # @api public
    class RelationProxy
      include Options
      include Relation::Materializable

      include RelationProxy::Combine
      include RelationProxy::Wrap

      option :name, type: Symbol
      option :mappers, reader: true, default: proc { MapperBuilder.new }
      option :meta, reader: true, type: Hash, default: EMPTY_HASH
      option :registry, type: RelationRegistry, default: proc { RelationRegistry.new }, reader: true

      # @!attribute [r] relation
      #   @return [Relation, Relation::Composite, Relation::Graph, Relation::Curried] The decorated relation object
      attr_reader :relation

      # @!attribute [r] name
      #   @return [ROM::Relation::Name] The relation name object
      attr_reader :name

      # @api private
      def initialize(relation, options = {})
        super
        @relation = relation
        @name = relation.name.with(options[:name])
      end

      # Materializes wrapped relation and sends it through a mapper
      #
      # For performance reasons a combined relation will skip mapping since
      # we only care about extracting key values for combining
      #
      # @api public
      def call(*args)
        ((combine? || composite?) ? relation : (relation >> mapper)).call(*args)
      end

      # Maps the wrapped relation with other mappers available in the registry
      #
      # @param *names [Array<Symbol, Class>] Either a list of mapper identifiers
      #                                      or a custom model class
      #
      # @return [RelationProxy] A new relation proxy with pipelined relation
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

      # Infers a mapper for the wrapped relation
      #
      # @return [ROM::Mapper]
      #
      # @api private
      def mapper
        mappers[to_ast]
      end

      # Returns a new instance with new options
      #
      # @param new_options [Hash]
      #
      # @return [RelationProxy]
      #
      # @api private
      def with(new_options)
        __new__(relation, new_options)
      end

      # Returns if this relation is combined aka a relation graph
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

      # Returns meta info for the wrapped relation
      #
      # @return [Hash]
      #
      # @api private
      def meta
        options[:meta]
      end

      # @return [Symbol] The wrapped relation's adapter identifier ie :sql or :http
      #
      # @api private
      def adapter
        relation.class.adapter
      end

      # Returns AST for the wrapped relation
      #
      # @return [Array]
      #
      # @api private
      def to_ast
        @to_ast ||=
          begin
            attr_ast = schema.map { |attr| [:attribute, attr] }

            meta = options[:meta].merge(dataset: base_name.dataset)
            meta.delete(:wraps)

            header = attr_ast + nodes_ast + wraps_ast

            [:relation, [base_name.relation, meta, [:header, header]]]
          end
      end

      # @api private
      def respond_to_missing?(meth, _include_private = false)
        relation.respond_to?(meth) || super
      end

      private

      # @api private
      def schema
        meta[:wrap] ? relation.schema.wrap.qualified : relation.schema.reject(&:wrapped?)
      end

      # @api private
      def base_name
        relation.base_name
      end

      # @api private
      def nodes_ast
        @nodes_ast ||= nodes.map(&:to_ast)
      end

      # @api private
      def wraps_ast
        @wraps_ast ||= wraps.map(&:to_ast)
      end

      # Return a new instance with another relation and options
      #
      # @return [RelationProxy]
      #
      # @api private
      def __new__(relation, new_options = EMPTY_HASH)
        self.class.new(
          relation, new_options.size > 0 ? options.merge(new_options) : options
        )
      end

      # Return all nodes that this relation combines
      #
      # @return [Array<RelationProxy>]
      #
      # @api private
      def nodes
        relation.graph? ? relation.nodes : EMPTY_ARRAY
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
    end
  end
end
