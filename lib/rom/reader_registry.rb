require 'rom/mapper_dsl'

module ROM

  class ReaderRegistry < Registry

    def call(relations, &block)
      dsl = MapperDSL.new(relations, self)
      dsl.instance_exec(&block)
      dsl.call
    end

  end

end
