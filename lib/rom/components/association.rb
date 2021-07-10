# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Association < Core
      option :gateway, type: Types.Instance(Symbol), inferrable: true

      option :object
      alias_method :definition, :object

      # Registry namespace
      #
      # @return [String]
      #
      # @api public
      def namespace
        options[:namespace]
      end

      # @api public
      def id
        definition.aliased? ? definition.as : definition.name
      end

      # @api public
      memoize def build
        association_class.new(definition, relations)
      end

      private

      # @api private
      def association_class
        ROM.adapters[adapter].const_get(:Associations).const_get(definition.type)
      end
    end
  end
end
