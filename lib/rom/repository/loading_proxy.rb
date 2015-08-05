require 'rom/support/options'
require 'rom/relation/materializable'

require 'rom/repository/loading_proxy/combine'
require 'rom/repository/loading_proxy/wrap'

module ROM
  class Repository < Gateway
    class LoadingProxy
      include Relation::Materializable
      include Options

      include LoadingProxy::Combine
      include LoadingProxy::Wrap

      option :name, reader: true, type: Symbol
      option :mapper_builder, reader: true, default: proc { MapperBuilder.new }
      option :meta, reader: true, type: Hash, default: EMPTY_HASH

      attr_reader :relation

      def initialize(relation, options = {})
        super
        @relation = relation
      end

      def call(*args)
        (combine? ? relation : (relation >> mapper)).call(*args)
      end

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

      def mapper
        mapper_builder[to_ast]
      end

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      def with(new_options)
        __new__(relation, new_options)
      end

      def combine?
        meta[:combine_type]
      end

      def meta
        options[:meta]
      end

      private

      def __new__(relation, new_options = {})
        self.class.new(relation, options.merge(new_options))
      end

      def nodes
        relation.is_a?(Relation::Graph) ? relation.nodes : []
      end

      def wraps
        meta.fetch(:wraps, [])
      end

      def method_missing(meth, *args)
        if relation.respond_to?(meth)
          result = relation.__send__(meth, *args)

          if result.is_a?(Relation::Lazy) || result.is_a?(Relation::Graph)
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
