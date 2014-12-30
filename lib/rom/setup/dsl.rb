require 'rom/setup/schema_dsl'
require 'rom/setup/mapper_dsl'
require 'rom/setup/command_dsl'

module ROM
  class Setup
    class DSL
      attr_reader :env

      def initialize(env)
        @env = env
        @schema = {}
      end

      def schema(&block)
        dsl = SchemaDSL.new(env, @schema)
        dsl.instance_exec(&block)
        dsl.call
      end

      def mappers(&block)
        dsl = MapperDSL.new
        dsl.instance_exec(&block)
        dsl.call
      end

      def commands(&block)
        dsl = CommandDSL.new
        dsl.instance_exec(&block)
        dsl.call
      end
    end
  end
end
