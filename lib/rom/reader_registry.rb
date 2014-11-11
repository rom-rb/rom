require 'rom/reader_registry/dsl'

module ROM

  class ReaderRegistry < Registry

    def self.define(relations, &block)
      dsl = DSL.new(relations)
      dsl.instance_exec(&block)
      dsl.call
    end

  end

end
