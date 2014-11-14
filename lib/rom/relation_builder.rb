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

    def call(&block)
      klass = build_class

      klass.class_eval(&block) if block

      new_relation = klass.new(relation.dataset, relation.header)
      relation.adapter_extensions.each { |ext| new_relation.extend(ext) }
      new_relation
    end

    def build_class
      klass_name = "#{Relation.name}[#{Inflecto.camelize(name)}]"

      klass = relations.map(&:class).detect { |c| c.name == klass_name }
      return klass if klass

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

        def inspect
          "#<#{klass_name} header=#\{header.inspect\} dataset=#\{dataset.inspect\}>"
        end

        def name
          #{name.inspect}
        end
      RUBY

      relation.adapter_inclusions.each { |ext| klass.send(:include, ext) }

      klass_mod = Module.new
      instance_mod = Module.new
      relations = self.relations

      builder = self

      schema.each do |name, relation|
        klass_mod.send(:define_method, name) { relations.key?(name) ? relations[name] : builder.new(name).build_class }
        instance_mod.send(:define_method, name) { relation.dataset }
      end

      klass.extend(klass_mod)
      klass.send(:include, instance_mod)

      klass
    end

    def new(name)
      self.class.new(name, schema, relations)
    end

  end

end
