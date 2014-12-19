require 'rom/mapper_builder'

module ROM
  class CommandDSL
    attr_reader :commands

    class CommandDefinition
      attr_reader :options

      def initialize(options, &block)
        @options = options
        instance_exec(&block) if block
      end

      def to_h
        options
      end

      def type
        options[:type]
      end

      def method_missing(name, *args, &block)
        if args.size == 1
          options[name] = args.first
        else
          super
        end
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
