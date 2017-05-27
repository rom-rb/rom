require 'rom/model_builder'

module ROM
  class Mapper
    # Model DSL allows setting a model class
    #
    # @private
    module ModelDSL
      attr_reader :attributes, :builder, :klass

      DEFAULT_TYPE = :poro

      # Set or generate a model
      #
      # @example
      #   class MyDefinition
      #     include ROM::Mapper::ModelDSL
      #
      #     def initialize
      #       @attributes = [[:name], [:title]]
      #     end
      #   end
      #
      #   definition = MyDefinition.new
      #
      #   # just set a model constant
      #   definition.model(User)
      #
      #   # generate model class for the attributes
      #   definition.model(name: 'User')
      #
      # @api public
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

      # Build a model class using a specialized builder
      #
      # @api private
      def build_class
        return klass if klass
        included_attrs = attributes.reject do |_name, opts|
          opts && opts[:exclude]
        end
        builder.call(included_attrs.map(&:first)) if builder
      end
    end
  end
end
