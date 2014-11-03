module ROM
  class MapperRegistry

    class ModelBuilder
      attr_reader :options, :const_name, :klass

      def self.[](type)
        case type
        when :poro then PORO
        else
          raise ArgumentError, "#{type.inspect} is not a supported model type"
        end
      end

      def self.call(*args)
        new(*args).call
      end

      def initialize(options)
        @options = options
        @const_name = options[:name]
      end

      def define_const
        Object.const_set(const_name, klass)
      end

      def call(attributes)
        define_class(attributes)
        define_const if const_name
      end

      class PORO < ModelBuilder

        def define_class(attributes)
          @klass = Class.new

          @klass.send(:attr_accessor, *attributes)

          ivar_list = attributes.map { |name| "@#{name}" }.join(", ")
          sym_list = attributes.map { |name| ":#{name}" }.join(", ")

          @klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(params)
              #{ivar_list} = params.values_at(#{sym_list})
            end
          RUBY

          self
        end

      end

    end
  end
end
