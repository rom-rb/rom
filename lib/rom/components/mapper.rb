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
      def id
        config[:id] || relation_id
      end

      # @api public
      def namespace
        "#{super}.#{relation_id}"
      end

      # @api public
      def build
        object || constant.build
      end

      # @api private
      def relation_id
        config[:relation_id]
      end
    end
  end
end
