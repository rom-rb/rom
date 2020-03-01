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
            if relation.schema?
              input = options.fetch(:input, self.input)
              relation_input = relation.input_schema

              input_handler =
                if input.equal?(ROM::Command.input)
                  relation_input
                else
                  -> tuple { relation_input[input[tuple]] }
                end

              super(relation, **options, input: input_handler)
            else
              super
            end
          end
        end
      end
    end
  end
end
