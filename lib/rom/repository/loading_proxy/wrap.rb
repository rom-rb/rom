module ROM
  class Repository < Gateway
    class LoadingProxy
      module Wrap
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
      end
    end
  end
end
