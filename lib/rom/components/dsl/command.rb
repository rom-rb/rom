# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # Command `define` DSL used by Setup#commands
      #
      # @private
      class Command < Core
        key :commands

        nested(true)

        # Define a command class
        #
        # @param [Symbol] name of the command
        # @param [Hash] options
        # @option options [Symbol] :type The type of the command
        #
        # @return [Class] generated class
        #
        # @api public
        def define(id, type: id, **options, &block)
          command_type = inflector.classify(type)
          parent = adapter_namespace.const_get(command_type)

          constant = build_class(name: class_name(command_type), parent: parent) do |dsl|
            config.update(options)

            config.component.update(dsl.config)
            config.component.update(id: id, adapter: dsl.adapter)

            class_exec(&block) if block
          end

          call(constant: constant, config: constant.config.component)
        end

        # @api private
        def class_name(command_type)
          class_name_inferrer[
            config[:relation],
            type: :command,
            inflector: inflector,
            adapter: adapter,
            command_type: command_type,
            class_namespace: provider.config.class_namespace
          ]
        end

        # @api private
        def adapter_namespace
          ROM::Command.adapter_namespace(adapter)
        end
      end
    end
  end
end
