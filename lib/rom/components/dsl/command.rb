# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # Command `define` DSL used by Setup#commands
      #
      # @private
      class Command < Core
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
            config.update(type: type, component: {id: id}, **options)
            class_exec(&block) if block
          end

          components.add(
            :commands, relation_id: relation, constant: constant, provider: self, **options
          )
        end

        # @api private
        def class_name(command_type)
          class_name_inferrer[
            relation,
            type: :command,
            inflector: inflector,
            adapter: adapter,
            command_type: command_type,
            **provider_config.components
          ]
        end

        # @api private
        def adapter_namespace
          ROM::Command.adapter_namespace(adapter)
        end

        # @api private
        def infer_option(option, component:)
          case option
          # id in the DSL is also resolved as command sub-class so we need to delegate
          # inferring to the class itself in case it defines its custom id
          when :id then component.constant.infer_option(option, component: component)
          when :relation_id then relation
          when :adapter then adapter
          end
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
