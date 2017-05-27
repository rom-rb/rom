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
        def wrap(*names, **options)
          new_wraps = wraps_from_names(names) + wraps_from_options(options)

          relation = new_wraps.reduce(self) { |a, e|
            name = e.meta[:wrap_from_assoc] ? e.meta[:combine_name] : e.base_name.relation
            a.relation.for_wrap(e.meta.fetch(:keys), name)
          }

          __new__(relation, meta: { wraps: wraps + new_wraps })
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
              keys = combine_keys(parent, relation, :children)
              h[name] = [parent, keys]
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
        def wrapped(name, keys, wrap_from_assoc = false)
          with(
            name: name,
            meta: {
              keys: keys, wrap_from_assoc: wrap_from_assoc, wrap: true, combine_name: name
            }
          )
        end

        # @api private
        def wraps_from_options(options)
          options.map { |(name, (relation, keys))| relation.wrapped(name, keys) }
        end

        # @api private
        def wraps_from_names(names)
          names.map { |name|
            assoc = associations[name]
            registry[assoc.target.relation].wrapped(name, assoc.combine_keys(__registry__), true)
          }
        end
      end
    end
  end
end
