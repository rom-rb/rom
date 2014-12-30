require 'rom/setup/base_relation_dsl'

module ROM
  class Setup
    class SchemaDSL
      attr_reader :env, :schema

      def initialize(env, schema, &block)
        @env = env
        @schema = schema
        instance_exec(&block)
      end

      def base_relation(name, &block)
        dsl = BaseRelationDSL.new(env, name, &block)
        schema[dsl.repository] ||= []
        schema[dsl.repository] << dsl.call
      end
    end
  end
end
