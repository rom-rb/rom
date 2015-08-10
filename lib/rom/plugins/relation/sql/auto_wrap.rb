module ROM
  module Plugins
    module Relation
      module SQL
        module AutoWrap
          # @api private
          def self.included(klass)
            super
            klass.include(InstanceInterface)
            klass.extend(ClassInterface)
          end

          module ClassInterface
            def inherited(klass)
              super
              klass.auto_curry :for_wrap
            end
          end

          module InstanceInterface
            # Default methods for fetching wrapped relation
            #
            # This method is used by default by `wrap` and `wrap_parents`
            #
            # @return [SQL::Relation]
            #
            # @api private
            def for_wrap(keys, name)
              other = __registry__[name]

              inner_join(name, keys)
                .select(*qualified.header.columns)
                .select_append(*other.prefix(other.name).qualified.header)
            end
          end
        end
      end
    end
  end

  plugins do
    adapter :sql do
      register :auto_wrap, Plugins::Relation::SQL::AutoWrap, type: :relation
    end
  end
end
