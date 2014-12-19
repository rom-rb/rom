module ROM

  # @api private
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

    def call(header)
      define_class(header)
      define_const if const_name
    end

    class PORO < ModelBuilder

      def define_class(header)
        @klass = Class.new

        attributes = header.keys

        @klass.send(:attr_accessor, *attributes)

        @klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(params)
            #{attributes.map { |name| "@#{name} = params[:#{name}]" }.join("\n")}
          end
        RUBY

        self
      end

    end

  end

end
