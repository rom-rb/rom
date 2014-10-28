module ROM
  class MapperRegistry

    class ModelBuilder
      attr_reader :attributes, :options

      def initialize(attributes, options)
        @attributes = attributes
        @options = options
      end

      def call
        raise NotImplementedError, "#{self.class}#call must be implemented"
      end

      class PORO < ModelBuilder
        def call
          klass = Class.new
          klass.send(:attr_accessor, *attributes)

          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(params)
              #{attributes.map { |name| "@#{name}" }.join(", ")} = params.values_at(#{attributes.map { |name| ":#{name}" }.join(", ")})
            end
          RUBY

          klass
        end
      end

    end
  end
end
