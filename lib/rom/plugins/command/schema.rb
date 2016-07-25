module ROM
  module Plugins
    module Command
      # @api private
      module Schema
        def self.included(klass)
          super
          klass.extend(ClassInterface)
        end

        # @api private
        module ClassInterface
          # @see Command.build
          # @api public
          def build(relation, options = {})
            if options.key?(:input) || !relation.schema?
              super
            else
              super(relation, options.merge(input: relation.schema_hash))
            end
          end
        end
      end
    end
  end
end
