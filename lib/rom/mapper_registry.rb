require 'rom/mapper_registry/dsl'

module ROM

  class MapperRegistry
    attr_reader :mappers

    def initialize(mappers = {})
      @mappers = mappers
    end

    def self.define(relations, &block)
      dsl = DSL.new(relations)
      dsl.instance_exec(&block)
      dsl.call
    end

    def [](name)
      mappers.fetch(name)
    end

    def []=(name, mapper)
      mappers[name] = mapper
    end

    def respond_to_missing?(name, include_private = false)
      mappers.key?(name)
    end

    private

    def method_missing(name)
      mappers.fetch(name)
    end

  end

end
