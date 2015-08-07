require 'rom/support/options'
require 'rom/relation/materializable'

require 'rom/repository/loading_proxy/combine'
require 'rom/repository/loading_proxy/wrap'

module ROM
  class Repository < Gateway
    # LoadingProxy decorates a relation and automatically generate mappers that
    # will map raw tuples into structs
    #
    # @api public
    class LoadingProxy
      include Options
      include Relation::Materializable

      include LoadingProxy::Combine
      include LoadingProxy::Wrap

      option :name, reader: true, type: Symbol
      option :mapper_builder, reader: true, default: proc { MapperBuilder.new }
      option :meta, reader: true, type: Hash, default: EMPTY_HASH

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
        mappers = [mapper]+names.map { |name| relation.mappers[name] }
        mappers.reduce(self) { |a, e| a >> e }
      end
      alias_method :as, :map_with

      # Return AST for this relation
      #
      # @return [Array]
      #
      # @api private
      def to_ast
        attr_ast = columns.map { |name| [:attribute, name] }

        node_ast = nodes.map(&:to_ast)
        wrap_ast = wraps.map(&:to_ast)

        wrap_attrs = wraps.flat_map { |wrap|
          wrap.columns.map { |c| [:attribute, :"#{wrap.base_name}_#{c}"] }
        }

        meta = options[:meta].merge(base_name: relation.base_name)
        meta.delete(:wraps)

        [:relation, name, [:header, (attr_ast - wrap_attrs) + node_ast + wrap_ast], meta]
      end

      # Infer a mapper for the relation
      #
      # @return [ROM::Mapper]
      #
      # @api private
      def mapper
        mapper_builder[to_ast]
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      # Return new instance with new options
      #
      # @return [LoadingProxy]
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

      private

      # Return a new instance with another relation and options
      #
      # @return [LoadingProxy]
      #
      # @api private
      def __new__(relation, new_options = {})
        self.class.new(relation, options.merge(new_options))
      end

      # Return all nodes that this relation combines
      #
      # @return [Array<LoadingProxy>]
      #
      # @api private
      def nodes
        relation.respond_to?(:nodes) ? relation.nodes : []
      end

      # Return all nodes that this relation wraps
      #
      # @return [Array<LoadingProxy>]
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
      def method_missing(meth, *args)
        if relation.respond_to?(meth)
          result = relation.__send__(meth, *args)

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
