require 'rom/mapper_builder'

module ROM

  class MapperDSL
    attr_reader :mappers

    def initialize
      @mappers = []
    end

    def call
      mappers
    end

    def define(name, options = {}, &block)
      mappers << [name, options, block]
      self
    end
  end

end
