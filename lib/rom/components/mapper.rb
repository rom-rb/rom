# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Mapper < Core
      # @!attribute [r] relation_id
      #   @return [Symbol]
      option :relation_id, type: Types::Strict::Symbol, inferrable: true

      # @!attribute [r] constant
      #   @return [Class] Component's target class
      option :constant, type: Types.Interface(:new), optional: true

      # @!attribute [r] object
      #   @return [Class] Pre-initialized object that should be used instead of the constant
      #   @api public
      option :object, optional: true

      # @api public
      def build
        object || constant.build
      end
    end
  end
end
