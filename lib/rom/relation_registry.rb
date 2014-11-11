require 'rom/registry'
require 'rom/relation_registry/dsl'

module ROM

  class RelationRegistry < Registry

    def self.define(schema, &block)
      dsl = DSL.new(schema)
      dsl.instance_exec(&block)
      dsl.call
    end

  end

end
