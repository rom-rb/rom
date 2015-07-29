require 'rom/support/options'

module ROM
  class Repository < Gateway
    class LoadingProxy
      include Options

      option :name, reader: true, type: Symbol
      option :mapper_builder, reader: true, default: proc { MapperBuilder.new }
      option :meta, reader: true, type: Hash, default: EMPTY_HASH

      attr_reader :relation

      def initialize(relation, options = {})
        super
        @relation = relation
      end

      def mapper
        mapper_builder[to_ast]
      end

      def header
        relation.columns
      end

      def combine(options)
        nodes = options.flat_map do |type, relations|
          relations.map { |key, relation|
            __new__(relation, name: key, meta: {
              key: { primary_key => foreign_key }, combine_type: type
            })
          }
        end

        __new__(relation.combine(*nodes))
      end

      def __new__(relation, new_options = {})
        self.class.new(relation, options.merge(new_options))
      end

      def to_a
        (relation >> mapper).to_a
      end

      def to_ast
        attrs = header.map { |name| [:attribute, name] }

        if relation.is_a?(Relation::Graph)
          [:relation, name, [:header, attrs + nodes.map(&:to_ast)], meta]
        else
          [:relation, name, [:header, attrs], meta]
        end
      end

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      private

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
