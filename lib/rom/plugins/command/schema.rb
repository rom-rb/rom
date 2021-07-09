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
            if relation.schema? && !options.key?(:input)
              schema = relation.input_schema
              input = config.input

              composed_input =
                if input.equal?(ROM::Command.config.input)
                  schema
                else
                  -> tuple { schema[input[tuple]] }
                end

              super(relation, **options, input: composed_input)
            else
              super
            end
          end
        end
      end
    end
  end
end
