module ROM
  class Repository < Gateway
    class LoadingProxy
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
        # @return [LoadingProxy]
        #
        # @api public
        def wrap(options)
          wraps = options.map { |(name, (relation, keys))|
            relation.wrapped(name, keys)
          }

          relation = wraps.reduce(self) { |a, e|
            a.relation.for_wrap(e.base_name, e.meta.fetch(:keys))
          }

          __new__(relation, meta: { wraps: wraps })
        end

        # Shortcut to wrap parents
        #
        # @example
        #   tasks.wrap_parent(owner: users)
        #
        # @return [LoadingProxy]
        #
        # @api public
        def wrap_parent(options)
          wrap(
            options.each_with_object({}) { |(name, parent), h|
              h[name] = [parent, combine_keys(parent, :children)]
            }
          )
        end

        # Return a wrapped representation of a loading-proxy relation
        #
        # This will carry meta info used to produce a correct AST from a relation
        # so that correct mapper can be generated
        #
        # @return [LoadingProxy]
        #
        # @api private
        def wrapped(name, keys)
          with(name: name, meta: { keys: keys, wrap: true })
        end
      end
    end
  end
end
