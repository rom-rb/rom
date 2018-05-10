module ROM
  module Associations
    # @api private
    class ThroughIdentifier
      # @api private
      attr_reader :source

      # @api private
      attr_reader :target

      # @api private
      attr_reader :assoc_name

      # @api private
      def self.[](source, target, assoc_name = nil)
        new(source, target, assoc_name || default_assoc_name(target))
      end

      # @api private
      def self.default_assoc_name(relation)
        ROM.inflector.singularize(relation).to_sym
      end

      # @api private
      def initialize(source, target, assoc_name)
        @source = source
        @target = target
        @assoc_name = assoc_name
      end

      # @api private
      def to_sym
        source
      end
    end
  end
end
