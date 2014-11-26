require 'rom/mapper_builder'

module ROM

  class CommandDSL
    attr_reader :commands

    class CommandDefinition
      def initialize(&block)
        @input = nil
        @validator = nil
        instance_exec(&block) if block
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
    end

    def initialize
      @commands = {}
    end

    def call
      commands
    end

    def define(name, &block)
      commands[name] = CommandDefinition.new(&block)
      self
    end

  end

end
