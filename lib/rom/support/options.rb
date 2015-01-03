module ROM
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

    module ClassMethods
      DEFAULTS = { type: Object, reader: false, allow: [] }.freeze

      def option_definitions
        @__options__ ||= {}
      end

      def option(name, settings = {})
        option_definitions[name] = DEFAULTS.merge(settings)
        attr_reader(name) if option_definitions[name][:reader]
      end

      def assert_valid_options(options)
        options.each do |key, value|
          assert_option_key(key)
          assert_option_value(key, value)
        end
      end

      def assert_option_key(key)
        unless option_definitions.key?(key)
          raise InvalidOptionKeyError,
            "#{key.inspect} is not a valid option"
        end
      end

      def assert_option_value(key, value)
        type, allow = option_definitions[key].values_at(:type, :allow)

        unless value.is_a?(type)
          raise InvalidOptionValueError,
            "#{key.inspect}:#{value.inspect} has incorrect type"
        end

        if allow.any? && !allow.include?(value)
          raise InvalidOptionValueError,
            "#{key.inspect}:#{value.inspect} has incorrect value"
        end
      end
    end

    def initialize(*args)
      options = args.last
      self.class.assert_valid_options(options)
      @options = options
      self.class.option_definitions.each do |name, settings|
        instance_variable_set("@#{name}", @options[name]) if settings[:reader]
      end
    end
  end
end
