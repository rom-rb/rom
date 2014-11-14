require 'rom/boot/schema_dsl'

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

    end

  end
end
