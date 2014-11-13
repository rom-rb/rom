require 'rom/schema_dsl'

module ROM

  class Schema < Registry

    def self.load_schema(env, schema)
      env.load_schema.each do |(name, dataset, header, ext)|
        relation = Relation.new(dataset, header)
        relation.extend(ext) if ext

        schema[name] = relation
      end
    end

    def call(env, &block)
      if block
        dsl = SchemaDSL.new(env, self)
        dsl.instance_exec(&block)
        dsl.call
      else
        self.class.load_schema(env, self)
      end

      self
    end

    def empty?
      elements.empty?
    end

  end

end
