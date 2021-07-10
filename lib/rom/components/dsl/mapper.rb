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
        def define(id, parent: id, inherit_header: ROM::Mapper.inherit_header, **options, &block)
          class_opts = {name: class_name(id), parent: class_parent(parent)}

          constant = build_class(**class_opts) do |dsl|
            config.update(inherit_header: inherit_header, component: {id: id, relation_id: parent})
            class_eval(&block) if block
          end

          add(provider: constant, constant: constant)
        end

        # @api private
        def class_parent(parent_id)
          components.get(:mappers, relation_id: parent_id)&.constant || ROM::Mapper
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
        def register(relation, mappers)
          mappers.map do |id, mapper|
            components.add(
              :mappers,
              id: id,
              relation_id: relation,
              object: mapper,
              provider: owner,
              namespace: "mappers.#{relation}"
            )
          end
        end
      end
    end
  end
end
