# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Mapper < Core
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

      # @api public
      def id
        config.id || relation
      end

      # @api public
      def relation
        config.relation
      end

      # @api public
      def namespace
        "#{super}.#{relation}"
      end
    end
  end
end
