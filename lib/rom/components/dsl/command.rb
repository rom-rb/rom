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
            config.component.id = id
            config.update(type: type, **options)
            class_exec(&block) if block
          end

          # Update component config via constant because it could've been changed
          config.update(constant.config.component.to_h)

          add(constant: constant, config: {adapter: adapter, **options})
        end

        # @api private
        def class_name(command_type)
          class_name_inferrer[
            config[:relation_id],
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

        # @api private
        def adapter
          _config.fetch(:adapter) { provider.config.gateways[config[:gateway]].adapter }
        end
      end
    end
  end
end
