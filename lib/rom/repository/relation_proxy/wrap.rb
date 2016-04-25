module ROM
  class Repository
    class RelationProxy
      # Provides convenient methods for producing wrapped relations
      #
      # @api public
      module Wrap
        # Wrap other relations
        #
        # @example
        #   tasks.wrap(owner: [users, user_id: :id])
        #
        # @param [Hash] options
        #
        # @return [RelationProxy]
        #
        # @api public
        def wrap(options)
          wraps = options.map { |(name, (relation, keys))|
            relation.wrapped(name, keys)
          }

          relation = wraps.reduce(self) { |a, e|
            a.relation.for_wrap(e.meta.fetch(:keys), e.base_name)
          }

          __new__(relation, meta: { wraps: wraps })
        end

        # Shortcut to wrap parents
        #
        # @example
        #   tasks.wrap_parent(owner: users)
        #
        # @return [RelationProxy]
        #
        # @api public
        def wrap_parent(options)
          wrap(
            options.each_with_object({}) { |(name, parent), h|
              h[name] = [parent, combine_keys(parent, relation, :children)]
            }
          )
        end

        # Return a wrapped representation of a loading-proxy relation
        #
        # This will carry meta info used to produce a correct AST from a relation
        # so that correct mapper can be generated
        #
        # @return [RelationProxy]
        #
        # @api private
        def wrapped(name, keys)
          with(name: name, meta: { keys: keys, wrap: true })
        end
      end
    end
  end
end
