require 'rom/schema/dsl'

module ROM

  class Schema < Registry

    def self.define(env, &block)
      if block
        dsl = DSL.new(env)
        dsl.instance_exec(&block)
        dsl.call
      else
        load_schema(env)
      end
    end

    def self.load_schema(env)
      env.load_schema.each_with_object(Schema.new) do |(name, dataset, header), schema|
        schema[name] = Relation.new(dataset, header)
      end
    end

  end

end
