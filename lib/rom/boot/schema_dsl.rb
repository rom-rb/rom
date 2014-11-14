require 'rom/boot/base_relation_dsl'

module ROM
  class Boot

    class SchemaDSL
      attr_reader :env, :schema

      def initialize(env, schema = {})
        @env = env
        @schema = schema
      end

      def base_relation(name, &block)
        schema[name] = BaseRelationDSL.new(env, name).call(&block)
      end

      def call
        schema
      end

    end

  end
end
