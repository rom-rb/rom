# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Mapper < Core
      id :mapper

      # @!attribute [r] relation_id
      #   @return [Symbol]
      option :relation_id, type: Types::Strict::Symbol, inferrable: true

      # @!attribute [r] base_relation
      #   @return [Symbol] The base relation identifier
      #   @api public
      option :base_relation, type: Types.Instance(Symbol), optional: true, reader: false

      # @!attribute [r] constant
      #   @return [Class] Component's target class
      option :constant, optional: true, type: Types.Interface(:new)

      # @!attribute [r] object
      #   @return [Class] Pre-initialized object that should be used instead of the constant
      #   @api public
      option :object, optional: true

      # Registry namespace
      #
      # @return [String]
      #
      # @api public
      def namespace
        options[:namespace] || "mappers.#{relation_id}"
      end

      # @api public
      def build
        object || constant.build
      end
    end
  end
end
