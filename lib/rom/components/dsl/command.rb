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

        # @!attribute [r] relation
        #   @return [Symbol] Relation id
        option :relation, type: Types::Strict::Symbol

        # @!attribute [r] input
        #   @return [#call] Input processor
        option :input, type: Types.Interface(:call), optional: true

        # @!attribute [r] adapter
        #   @return [Symbol] Relation id
        option :adapter, type: Types::Strict::Symbol, optional: true, default: -> {
          resolve_adapter
        }

        nested(true)

        settings(:input, component: [:adapter, {relation: :relation_id}])

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

          add(relation_id: relation, constant: constant, provider: constant)
        end

        # @api private
        def class_name(command_type)
          class_name_inferrer[
            relation,
            type: :command,
            inflector: inflector,
            adapter: adapter,
            command_type: command_type,
            **config.components
          ]
        end

        # @api private
        def adapter_namespace
          ROM::Command.adapter_namespace(adapter)
        end

        private

        # @api private
        def resolve_adapter
          components.relations(id: relation).first&.adapter
        end
      end
    end
  end
end
