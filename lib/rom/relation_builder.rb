module ROM
  # This class builds a ROM::Relation subclass and instantiates it by injecting
  # dataset defined in the schema along with its header
  #
  # Relation objects created by this builder are accessible through relation
  # registry in the env object
  #
  # @private
  class RelationBuilder
    attr_reader :schema, :mod

    # @param [Schema]
    # @param [Hash] relation registry
    #
    # @api private
    def initialize(schema, relations)
      @schema = schema

      @mod = Module.new

      @mod.module_exec do
        define_method(:__relations__) { relations }
      end
    end

    # Builds relation class and return its instance
    #
    # @param [Symbol] name of the relation
    #
    # @return [Relation]
    #
    # @api private
    def call(name)
      schema_relation = schema[name]
      klass_name = "#{Relation.name}[#{Inflecto.camelize(name)}]"

      klass = build_class(name, klass_name)
      klass.send(:include, mod)

      yield(klass)

      klass.new(schema_relation.dataset, schema_relation.header)
    end

    private

    # Builds class constant for the relation
    #
    # @param [Symbol] name of the relation
    # @param [String] name of the relation class
    #
    # @return [Class]
    #
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

          def method_missing(name, *)
            __relations__.fetch(name) { super }
          end
        RUBY
      end
    end
  end
end
