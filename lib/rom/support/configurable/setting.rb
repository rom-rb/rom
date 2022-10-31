# frozen_string_literal: true

require "set"

require "rom/support/configurable/config"

module ROM
  module Configurable
    # This class represents a setting and is used internally.
    #
    # @api private
    class Setting
      include Dry::Equalizer(:name, :value, :options, inspect: false)

      OPTIONS = %i[input default reader constructor cloneable settings].freeze

      DEFAULT_CONSTRUCTOR = -> v { v }.freeze

      CLONEABLE_VALUE_TYPES = [Array, Hash, Set, Config].freeze

      # @api private
      attr_reader :name

      # @api private
      attr_reader :writer_name

      # @api private
      attr_reader :input

      # @api private
      attr_reader :default

      # @api private
      attr_reader :options

      # Specialized Setting which includes nested settings
      #
      # @api private
      class Nested < Setting
        CONSTRUCTOR = Config.method(:new)

        # @api private
        def pristine
          with(input: input.pristine)
        end

        # @api private
        def constructor
          CONSTRUCTOR
        end
      end

      # @api private
      def self.cloneable_value?(value)
        CLONEABLE_VALUE_TYPES.any? { |type| value.is_a?(type) }
      end

      # @api private
      def initialize(name, input: Undefined, default: Undefined, **options)
        @name = name
        @writer_name = :"#{name}="
        @options = options

        # Setting collections (see `Settings`) are shared between the configurable class
        # and its `config` object, so for cloneable individual settings, we duplicate
        # their _values_ as early as possible to ensure no impact from unintended mutation
        @input = input
        @default = default
        if cloneable?
          @input = input.dup
          @default = default.dup
        end

        evaluate if input_defined?
      end

      # @api private
      def input_defined?
        !input.equal?(Undefined)
      end

      # @api private
      def value
        @value ||= evaluate
      end

      # @api private
      def evaluated?
        instance_variable_defined?(:@value)
      end

      # @api private
      def nested(settings)
        Nested.new(name, input: settings, **options)
      end

      # @api private
      def pristine
        with(input: Undefined)
      end

      # @api private
      def with(new_opts)
        self.class.new(name, input: input, default: default, **options, **new_opts)
      end

      # @api private
      def constructor
        options[:constructor] || DEFAULT_CONSTRUCTOR
      end

      # @api private
      def reader?
        options[:reader].equal?(true)
      end

      # @api private
      def writer?(meth)
        writer_name.equal?(meth)
      end

      # @api private
      def cloneable?
        if options.key?(:cloneable)
          # Return cloneable option if explicitly set
          options[:cloneable]
        else
          # Otherwise, infer cloneable from any of the input, default, or value
          Setting.cloneable_value?(input) || Setting.cloneable_value?(default) || (
            evaluated? && Setting.cloneable_value?(value)
          )
        end
      end

      private

      # @api private
      def initialize_copy(source)
        super

        @options = source.options.dup

        if source.cloneable?
          @input = source.input.dup
          @default = source.default.dup
          @value = source.value.dup if source.evaluated?
        end
      end

      # @api private
      def evaluate
        @value = constructor[Undefined.coalesce(input, default, nil)]
      end
    end
  end
end
