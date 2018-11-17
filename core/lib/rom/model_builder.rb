require 'rom/support/inflector'

module ROM
  # Model builders can be used to build model classes for mappers
  #
  # This is used when you define a mapper and setup a model using :name option.
  #
  # @example
  #   # this will define User model for you
  #   class UserMapper < ROM::Mapper
  #     model name: 'User'
  #     attribute :id
  #     attribute :name
  #   end
  #
  # @private
  class ModelBuilder
    attr_reader :name

    attr_reader :const_name, :namespace, :klass

    # Return model builder subclass based on type
    #
    # @param [Symbol] type
    #
    # @return [Class]
    #
    # @api private
    def self.[](type)
      case type
      when :poro then PORO
      else
        raise ArgumentError, "#{type.inspect} is not a supported model type"
      end
    end

    # Build a model class
    #
    # @return [Class]
    #
    # @api private
    def self.call(*args)
      new(*args).call
    end

    # @api private
    def initialize(options = {})
      @name = options[:name]

      if name
        parts = name.split('::')

        @const_name = parts.pop

        @namespace =
          if parts.any?
            Inflector.constantize(parts.join('::'))
          else
            Object
          end
      end
    end

    # Define a model class constant
    #
    # @api private
    def define_const
      namespace.const_set(const_name, klass)
    end

    # Build a model class supporting specific attributes
    #
    # @return [Class]
    #
    # @api private
    def call(attrs)
      define_class(attrs)
      define_const if const_name
      @klass
    end

    # PORO model class builder
    #
    # @private
    class PORO < ModelBuilder
      def define_class(attrs)
        @klass = Class.new

        @klass.send(:attr_reader, *attrs)

        @klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(params)
            #{attrs.map { |name| "@#{name} = params[:#{name}]" }.join("\n")}
          end
        RUBY

        self
      end
    end
  end
end
