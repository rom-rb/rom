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
            input_processor =
              if relation.schema
                Types::Hash.schema(relation.schema.attributes)
              else
                input
              end

            super(relation, options.merge(input: input_processor))
          end
        end
      end
    end
  end
end
