require 'rom/model_builder'

module ROM
  class MapperBuilder
    module ModelDSL
      attr_reader :attributes, :builder, :klass

      DEFAULT_TYPE = :poro

      def initialize(*)
        @klass = nil
        @builder = nil
      end

      def model(options = nil)
        if options.is_a?(Class)
          @klass = options
        elsif options
          type = options.fetch(:type) { DEFAULT_TYPE }
          @builder = ModelBuilder[type].new(options)
        end

        build_class unless options
      end

      private

      def build_class
        return klass if klass
        return builder.call(attributes.map(&:first)) if builder
      end
    end
  end
end
