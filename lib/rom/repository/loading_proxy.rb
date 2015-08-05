require 'rom/support/options'
require 'rom/relation/materializable'

module ROM
  class Repository < Gateway
    class LoadingProxy
      include Relation::Materializable
      include Options

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

      def wrap(options)
        wraps = options.map { |(name, (relation, keys))|
          relation.wrapped(name, keys)
        }

        relation = wraps.reduce(self) { |a, e|
          a.relation.for_wrap(e.base_name, e.meta.fetch(:keys))
        }

        __new__(relation, meta: { wraps: wraps })
      end

      def wrap_parent(options)
        wrap(
          options.each_with_object({}) { |(name, parent), h|
            h[name] = [parent, combine_keys(parent, :children)]
          }
        )
      end

      def wrapped(name, keys)
        with(name: name, meta: { keys: keys, wrap: true })
      end

      def combine(options)
        combine_opts = options.each_with_object({}) do |(type, relations), result|
          result[type] = relations.each_with_object({}) do |(name, (other, keys)), h|
            h[name] = [
              other.curried? ? other : other.combine_method(relation, keys), keys
            ]
          end
        end

        nodes = combine_opts.flat_map do |type, relations|
          relations.map { |name, (relation, keys)|
            relation.combined(name, keys, type)
          }
        end

        __new__(relation.combine(*nodes))
      end

      def combine_parents(options)
        combine_opts = options.each_with_object({}) { |(type, parents), h|
          h[type] = parents.each_with_object({}) { |(key, parent), r|
            r[key] = [parent, combine_keys(parent, :parent)]
          }
        }
        combine(combine_opts)
      end

      def combine_children(options)
        combine(options.each_with_object({}) { |(type, children), h|
          h[type] = children.each_with_object({}) { |(key, child), r|
            r[key] = [child, combine_keys(relation, :children)]
          }
        })
      end

      def combine_keys(relation, type)
        if type == :parent
          { relation.foreign_key => relation.primary_key }
        else
          { relation.primary_key => relation.foreign_key }
        end
      end

      def combine_method(other, keys)
        custom_name = :"for_#{other.base_name}"

        if relation.respond_to?(custom_name)
          __send__(custom_name)
        else
          for_combine(keys)
        end
      end

      def combined(name, keys, type)
        with(name: name, meta: { keys: keys, combine_type: type })
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
