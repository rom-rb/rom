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
        # @api private
        def call
          instance_exec(&block)
          self
        end

        # Define a mapper class
        #
        # @param [Symbol] id Mapper identifier
        # @param [Hash] options
        #
        # @return [Class]
        #
        # @api public
        def define(id, parent: nil, inherit_header: ROM::Mapper.inherit_header, **options, &block)
          name = class_name(id)

          parent = class_parent(parent)

          constant = build_class(name: name, parent: parent) do |dsl|
            register_as(id)
            relation(id)
            inherit_header(inherit_header)

            class_eval(&block) if block
          end

          components.add(:mappers, constant: constant, provider: self, **options)
        end

        # @api private
        def class_parent(parent_id)
          if parent_id
            components.mappers(relation_id: parent_id).first&.constant || ROM::Mapper
          else
            ROM::Mapper
          end
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
            components.add(:mappers, id: id, base_relation: relation, object: mapper)
          end
        end

        # @api private
        def infer_option(option, component:)
          case option
          when :id then component.constant.register_as
          when :relation_id then component.constant.base_relation
          end
        end
      end
    end
  end
end
