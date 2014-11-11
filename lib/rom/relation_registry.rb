require 'rom/registry'
require 'rom/relation_dsl'

module ROM

  class RelationRegistry < Registry

    def self.define(schema, &block)
      dsl = RelationDSL.new(schema)
      dsl.instance_exec(&block)
      dsl.call
    end

  end

end
