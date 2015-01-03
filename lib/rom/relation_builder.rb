module ROM
  # @api private
  class RelationBuilder
    attr_reader :schema, :mod

    # @api private
    def initialize(schema, relations)
      @schema = schema

      @mod = Module.new

      @mod.module_exec do
        define_method(:__relations__) { relations }
      end
    end

    # @api private
    def call(name)
      schema_relation = schema[name]
      klass_name = "#{Relation.name}[#{Inflecto.camelize(name)}]"

      klass = build_class(name, klass_name)
      klass.send(:include, mod)

      yield(klass)

      klass.new(schema_relation.dataset, schema_relation.header)
    end

    # @api private
    def build_class(name, klass_name)
      ClassBuilder.new(name: klass_name, parent: Relation).call do |klass|
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def name
            #{name.inspect}
          end

          def respond_to_missing?(name, _include_private = false)
            __relations__.key?(name) || super
          end

          private

          def method_missing(name, *args, &block)
            if __relations__.key?(name)
              __relations__[name]
            else
              super
            end
          end
        RUBY
      end
    end
  end
end
