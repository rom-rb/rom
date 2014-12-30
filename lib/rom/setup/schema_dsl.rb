require 'rom/setup/base_relation_dsl'

module ROM
  class Setup
    # @private
    class SchemaDSL
      attr_reader :env, :schema

      # @api private
      def initialize(env, schema, &block)
        @env = env
        @schema = schema
        initialize_schema
        instance_exec(&block)
      end

      # @api public
      def base_relation(name, &block)
        dsl = BaseRelationDSL.new(env, name, &block)
        schema[dsl.repository] << dsl.call
      end

      private

      # @api private
      def initialize_schema
        env.repositories.each_value do |repository|
          schema[repository] ||= []
        end
      end
    end
  end
end
