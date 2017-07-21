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
              default_input = options.fetch(:input, input)

              input_handler =
                if default_input != Hash
                  -> tuple { relation.input_schema[input[tuple]] }
                else
                  relation.input_schema
                end

              super(relation, options.merge(input: input_handler))
            end
          end
        end
      end
    end
  end
end
