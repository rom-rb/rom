require 'rom/mapper_builder'

module ROM

  class CommandDSL
    attr_reader :commands

    class CommandDefinition
      attr_reader :options

      def initialize(options, &block)
        @options = options
        @input = Hash
        @validator = Proc.new {}
        @result = nil
        instance_exec(&block) if block
      end

      def to_h
        { input: input, validator: validator, result: result }
      end

      def input(klass = nil)
        if klass
          @input = klass
        else
          @input
        end
      end

      def validator(klass = nil)
        if klass
          @validator = klass
        else
          @validator
        end
      end

      def result(value = nil)
        if value
          @result = value
        else
          @result
        end
      end

      def type
        options[:type]
      end
    end

    def initialize
      @commands = {}
    end

    def call
      commands
    end

    def define(name, options = {}, &block)
      commands[name] = CommandDefinition.new(options, &block)
      self
    end

  end

end
