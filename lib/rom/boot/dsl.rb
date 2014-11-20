require 'rom/boot/schema_dsl'
require 'rom/boot/mapper_dsl'

module ROM
  class Boot

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

    end

  end
end
