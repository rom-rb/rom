# frozen_string_literal: true

module ROM
  module Plugins
    module Command
      # Command plugin which sets input processing function via relation schema
      #
      # @api private
      module Schema
        def self.included(klass)
          super
          klass.extend(ClassInterface)
        end

        # @api private
        module ClassInterface
          # Build a command and set it input to relation's input_schema
          #
          # @see Command.build
          #
          # @return [Command]
          #
          # @api public
          def build(relation, **options)
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

              super(relation, **options, input: input_handler)
            end
          end
        end
      end
    end
  end
end
