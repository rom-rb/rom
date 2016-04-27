module ROM
  class Repository
    class RelationProxy
      # Provides convenient methods for producing combined relations
      #
      # @api public
      module Combine
        # Combine with other relations
        #
        # @example
        #   # combining many
        #   users.combine(many: { tasks: [tasks, id: :task_id] })
        #   users.combine(many: { tasks: [tasks.for_users, id: :task_id] })
        #
        #   # combining one
        #   users.combine(one: { task: [tasks, id: :task_id] })
        #
        # @param [Hash] options
        #
        # @return [RelationProxy]
        #
        # @api public
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

        # Shortcut for combining with parents which infers the join keys
        #
        # @example
        #   tasks.combine_parents(one: users)
        #
        # @param [Hash] options
        #
        # @return [RelationProxy]
        #
        # @api public
        def combine_parents(options)
          combine(options.each_with_object({}) { |(type, parents), h|
            h[type] =
              if parents.is_a?(Hash)
                parents.each_with_object({}) { |(key, parent), r|
                  r[key] = [parent, combine_keys(parent, relation, :parent)]
                }
              else
                (parents.is_a?(Array) ? parents : [parents])
                  .each_with_object({}) { |parent, r|
                  r[parent.combine_tuple_key(type)] = [
                    parent, combine_keys(parent, relation, :parent)
                  ]
                }
              end
          })
        end

        # Shortcut for combining with children which infers the join keys
        #
        # @example
        #   users.combine_parents(many: tasks)
        #
        # @param [Hash] options
        #
        # @return [RelationProxy]
        #
        # @api public
        def combine_children(options)
          combine(options.each_with_object({}) { |(type, children), h|
            h[type] =
              if children.is_a?(Hash)
                children.each_with_object({}) { |(key, child), r|
                  r[key] = [child, combine_keys(relation, child, :children)]
                }
              else
                (children.is_a?(Array) ? children : [children])
                  .each_with_object({}) { |child, r|
                  r[child.combine_tuple_key(type)] = [
                    child, combine_keys(relation, child, :children)
                  ]
                }
              end
          })
        end

        # Infer join keys for a given relation and association type
        #
        # @param [RelationProxy] relation
        # @param [Symbol] type The type can be either :parent or :children
        #
        # @return [Hash<Symbol=>Symbol>]
        #
        # @api private
        def combine_keys(source, target, type)
          assoc = source.schema && source.schema.associations[target.base_name]

          if assoc
            assoc.combine_keys(__registry__)
          else
            primary_key = source.primary_key
            foreign_key = target.foreign_key(source)

            if type == :parent
              { foreign_key => primary_key }
            else
              { primary_key => foreign_key }
            end
          end
        end

        # Infer relation for combine operation
        #
        # By default it uses `for_combine` which is implemented as SQL::Relation
        # extension
        #
        # @return [RelationProxy]
        #
        # @api private
        def combine_method(other, keys)
          custom_name = :"for_#{other.base_name}"

          if relation.respond_to?(custom_name)
            __send__(custom_name)
          else
            for_combine(
              (other.schema && other.schema.associations[base_name]) || keys
            )
          end
        end

        # Infer key under which a combine relation will be loaded
        #
        # @return [Symbol]
        #
        # @api private
        def combine_tuple_key(arity)
          if arity == :one
            Inflector.singularize(base_name).to_sym
          else
            base_name
          end
        end

        # Return combine representation of a loading-proxy relation
        #
        # This will carry meta info used to produce a correct AST from a relation
        # so that correct mapper can be generated
        #
        # @return [RelationProxy]
        #
        # @api private
        def combined(name, keys, type)
          with(name: name, meta: { keys: keys, combine_type: type })
        end
      end
    end
  end
end
