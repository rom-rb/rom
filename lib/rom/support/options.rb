module ROM
  # Helper module for classes with a constructor accepting option hash
  #
  # This allows us to DRY up code as option hash is a very common pattern used
  # accross the codebase. It is an internal implementation detail not meant to
  # be used outside of the library
  #
  # @private
  module Options
    attr_reader :options

    def self.included(klass)
      klass.class_eval do
        extend(ClassMethods)

        def self.inherited(descendant)
          descendant.instance_variable_set('@__options__', option_definitions)
        end
      end
    end

    class Option
      attr_reader :name, :type, :allow, :default

      def initialize(name, options = {})
        @name = name
        @type = options.fetch(:type) { Object }
        @reader = options.fetch(:reader) { false }
        @allow = options.fetch(:allow) { [] }
        @default = options.fetch(:default) { Undefined }
      end

      def reader?
        @reader
      end

      def default?
        @default != Undefined
      end

      def default_value(object)
        default.is_a?(Proc) ? default.call(object) : default
      end

      def type_matches?(value)
        value.is_a?(type)
      end

      def allow?(value)
        allow.none? || allow.include?(value)
      end
    end

    class Definitions
      def initialize
        @options = {}
      end

      def define(option)
        @options[option.name] = option
      end

      def validate_options(options)
        options.each do |name, value|
          validate_option_value(name, value)
        end
      end

      def set_defaults(object, options)
        each do |name, option|
          next unless option.default? && !options.key?(name)
          options[name] = option.default_value(object)
        end
      end

      def each(&block)
        @options.each(&block)
      end

      private

      def validate_option_value(name, value)
        option = @options.fetch(name) do
          raise InvalidOptionKeyError,
            "#{name.inspect} is not a valid option"
        end

        unless option.type_matches?(value)
          raise InvalidOptionValueError,
            "#{name.inspect}:#{value.inspect} has incorrect type"
        end

        unless option.allow?(value)
          raise InvalidOptionValueError,
            "#{name.inspect}:#{value.inspect} has incorrect value"
        end
      end
    end

    module ClassMethods
      def option_definitions
        @__options__ ||= Definitions.new
      end

      def option(name, settings = {})
        option = Option.new(name, settings)
        option_definitions.define(option)
        attr_reader(name) if option.reader?
      end
    end

    def initialize(*args)
      @options = args.last.dup
      definitions = self.class.option_definitions
      definitions.set_defaults(self, @options)
      definitions.validate_options(@options)
      definitions.each do |name, option|
        instance_variable_set("@#{name}", @options[name]) if option.reader?
      end
    end
  end
end
