require 'rom/mapper_dsl'

module ROM

  class ReaderRegistry < Registry

    def self.define(relations, &block)
      dsl = MapperDSL.new(relations)
      dsl.instance_exec(&block)
      dsl.call
    end

  end

end
