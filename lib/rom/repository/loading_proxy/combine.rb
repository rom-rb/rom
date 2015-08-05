module ROM
  class Repository < Gateway
    class LoadingProxy
      module Combine
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
            h[type] =
              if children.is_a?(Hash)
                children.each_with_object({}) { |(key, child), r|
                  r[key] = [child, combine_keys(relation, :children)]
                }
              else
                (children.is_a?(Array) ? children : [children])
                  .each_with_object({}) { |child, r|
                  r[child.combine_tuple_key(type)] = [
                    child, combine_keys(relation, :children)
                  ]
                }
              end
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

        def combine_tuple_key(arity)
          if arity == :one
            Inflector.singularize(base_name).to_sym
          else
            base_name
          end
        end

        def combined(name, keys, type)
          with(name: name, meta: { keys: keys, combine_type: type })
        end
      end
    end
  end
end
