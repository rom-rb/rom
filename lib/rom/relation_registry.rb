require 'rom/registry'

module ROM

  class RelationRegistry < Registry

    def call(schema, &block)
      dsl = RelationDSL.new(schema, self)
      dsl.instance_exec(&block)
      dsl.call
    end

  end

end
