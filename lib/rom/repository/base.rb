require 'rom/repository/ext/relation'

require 'rom/repository/mapper_builder'
require 'rom/repository/loading_proxy'

module ROM
  class Repository < Gateway
    class Base # :trollface:
      def self.relations(*names)
        if names.any?
          attr_reader(*names)
          @relations = names
        else
          @relations
        end
      end

      def self.new(env, mapper_builder = MapperBuilder.new)
        super
      end

      def initialize(env, mapper_builder)
        self.class.relations.each do |name|
          proxy = LoadingProxy.new(
            env.relation(name), name: name, mapper_builder: mapper_builder
          )
          instance_variable_set("@#{name}", proxy)
        end
      end

      def combine(root, options)
        combine_opts = options.each_with_object({}) do |(type, relations), result|
          result[type] = relations.each_with_object({}) do |(key, (relation, *args)), h|
            h[key] = [relation.for_combine(*args), *args]
          end
        end
        root.combine(combine_opts)
      end

      def combine_parents(root, options)
        combine(root, options.each_with_object({}) { |(type, relations), h|
          h[type] = relations.each_with_object({}) { |(key, relation), r|
            r[key] = [relation, combine_keys(relation, :parent)]
          }
        })
      end

      def combine_children(root, options)
        combine(root, options.each_with_object({}) { |(type, relations), h|
          h[type] = relations.each_with_object({}) { |(key, relation), r|
            r[key] = [relation, combine_keys(root, :children)]
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
    end
  end
end
