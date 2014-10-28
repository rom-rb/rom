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

          klass.class_eval do
            def initialize(params)
              params.each do |name, value|
                send("#{name}=", value)
              end
            end
          end

          klass
        end
      end

    end
  end
end
