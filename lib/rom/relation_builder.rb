require 'inflecto'

module ROM

  class RelationBuilder
    attr_reader :name, :schema, :relations, :relation

    def initialize(name, schema, relations)
      @name = name
      @schema = schema
      @relations = relations

      @relation = schema[name]
    end

    def call
      klass_name = "#{Relation.name}[#{Inflecto.camelize(name)}]"

      klass = Class.new(Relation)

      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.name
          #{klass_name.inspect}
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

      mod = schema.each_with_object(Module.new) do |(name, relation), m|
        m.send(:define_method, name) { relation.dataset }
      end

      klass.send(:include, mod)

      yield(klass)

      klass.new(relation.dataset, relation.header)
    end

  end

end
