# frozen_string_literal: true

require "dry/core/class_builder"

require_relative "core"

module ROM
  module Components
    module DSL
      # Mapper definition DSL used by Setup DSL
      #
      # @private
      class Mapper < Core
        key(:mappers)

        nested(true)

        # Define a mapper class
        #
        # @param [Symbol] id Mapper identifier
        # @param [Hash] options
        #
        # @return [Class]
        #
        # @api public
        def define(id, parent: id, **options, &block)
          class_opts = {name: class_name(id), parent: class_parent(parent)}

          constant = build_class(**class_opts) do |dsl|
            config.update(options)

            config.component.update(id: id, relation: parent)
            config.component.join!({namespace: parent}, :right) if dsl.config.namespace != parent

            class_eval(&block) if block
          end

          call(constant: constant, config: constant.config.component)
        end

        # @api private
        def class_parent(parent)
          components.get(:mappers, relation: parent)&.constant || ROM::Mapper
        end

        # @api private
        def class_name(id)
          "ROM::Mapper[#{id}]"
        end

        # Register any object as a mapper for a given relation
        #
        # @param [Symbol] relation The relation registry id
        # @param [Hash<Symbol, Object>] mappers A hash with mapper objects
        #
        # @return [Array<Components::Mapper>]
        #
        # @api public
        def register(namespace, mappers)
          mappers.map do |id, mapper|
            call(
              object: mapper,
              config: config.join({id: id, relation: namespace, namespace: namespace}, :right)
            )
          end
        end
      end
    end
  end
end
