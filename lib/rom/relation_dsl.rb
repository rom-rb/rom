require 'inflecto'
require 'rom/relation_builder'

module ROM

  class RelationDSL
    attr_reader :schema, :relations

    def initialize(schema, relations)
      @schema = schema
      @relations = relations
    end

    def register(name, &block)
      builder = RelationBuilder.new(name, schema, relations)
      relation = builder.call(&block)

      relations << relation
    end

    def call
      relations
    end

  end

end
