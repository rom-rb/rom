require 'rom/schema_dsl'

module ROM

  class Schema < Registry

    def self.define(env, &block)
      if block
        dsl = SchemaDSL.new(env)
        dsl.instance_exec(&block)
        dsl.call
      else
        load_schema(env)
      end
    end

    def self.load_schema(env)
      env.load_schema.each_with_object(new) do |(name, dataset, header), schema|
        schema[name] = Relation.new(dataset, header)
      end
    end

  end

end
