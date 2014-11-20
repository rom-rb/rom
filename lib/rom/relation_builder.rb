module ROM

  class RelationBuilder
    attr_reader :schema, :mod

    def initialize(schema)
      @schema = schema
      @mod = schema.each_with_object(Module.new) do |(name, relation), m|
        m.send(:define_method, name) { relation.dataset }
      end
    end

    def call(name)
      schema_relation = schema[name]

      klass = Class.new(Relation)

      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.name
          "#{Relation.name}[#{Inflecto.camelize(name)}]"
        end

        def self.inspect
          name
        end

        def self.to_s
          name
        end

        def name
          #{name.inspect}
        end
      RUBY

      klass.send(:include, mod)

      yield(klass)

      klass.new(schema_relation.dataset, schema_relation.header)
    end

  end

end
