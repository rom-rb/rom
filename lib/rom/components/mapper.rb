# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Mapper < Core
      id :mapper

      # @!attribute [r] base_relation
      #   @return [Symbol] The base relation identifier
      #   @api public
      option :base_relation, type: Types.Instance(Symbol), optional: true, reader: false

      # @!attribute [r] object
      #   @return [Class] Pre-initialized object that should be used instead of the constant
      #   @api public
      option :object, optional: true

      # Relation registry id
      #
      # @return [Symbol]
      #
      # @api public
      def relation_id
        options[:base_relation] || constant.base_relation
      end

      # Registry id
      #
      # @return [Symbol]
      #
      # @api public
      def id
        options[:id] || constant.id
      end

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
