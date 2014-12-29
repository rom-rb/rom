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

      klass.send(:include, mod)

      yield(klass)

      klass.new(schema_relation.dataset, schema_relation.header)
    end
  end
end
