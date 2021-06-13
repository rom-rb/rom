# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Mapper < Core
      id :mapper

      # @!attribute [r] key
      #   @return [Symbol] The mapper identifier
      #   @api public
      option :key, type: Types.Instance(Symbol), default: -> {
        # TODO: another workaround for auto_register specs not using actual rom classes
        constant.respond_to?(:register_as) ?
          (constant.register_as || constant.relation) : constant.name.to_sym
      }

      # @!attribute [r] base_relation
      #   @return [Symbol] The base relation identifier
      #   @api public
      option :base_relation, type: Types.Instance(Symbol), default: -> {
        # TODO: another workaround for auto_register specs not using actual rom classes
        constant.respond_to?(:base_relation) ? constant.base_relation : constant.name.to_sym
      }

      # @!attribute [r] object
      #   @return [Class] Pre-initialize object that should be used instead of the constant
      #   @api public
      option :object, optional: true

      # @api public
      def id
        "#{base_relation}.#{key}"
      end

      # @api public
      def build
        object || constant.build
      end
    end
  end
end
