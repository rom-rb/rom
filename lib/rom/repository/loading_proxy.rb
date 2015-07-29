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

      def each
        return to_enum unless block_given?
        to_a.each { |item| yield(item) }
      end

      def first
        to_a.first
      end

      def one
        (relation >> mapper).one
      end

      def one!
        (relation >> mapper).one!
      end

      def to_a
        (relation >> mapper).to_a
      end

      def combine(options)
        nodes = options.flat_map do |type, relations|
          relations.map { |key, (relation, keys)|
            __new__(relation, name: key, meta: {
              keys: keys, combine_type: type
            })
          }
        end

        __new__(relation.combine(*nodes))
      end

      def to_ast
        attr_ast = header.map { |name| [:attribute, name] }
        node_ast = nodes.map(&:to_ast)
        meta = options[:meta].merge(base_name: relation.base_name)

        [:relation, name, [:header, attr_ast + node_ast], meta]
      end

      def mapper
        mapper_builder[to_ast]
      end

      def header
        relation.columns
      end

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      private

      def __new__(relation, new_options = {})
        self.class.new(relation, options.merge(new_options))
      end

      def nodes
        relation.is_a?(Relation::Graph) ? relation.nodes : []
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
