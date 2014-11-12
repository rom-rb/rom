require 'rom/mapper_builder'

module ROM

  class MapperDSL
    attr_reader :relations, :readers

    def initialize(relations, readers)
      @relations = relations
      @readers = readers
    end

    def call
      readers
    end

    def define(name, options = {}, &block)
      parent = options.fetch(:parent) { relations[name] }

      builder = MapperBuilder.new(name, parent, options)
      builder.instance_exec(&block)
      mapper = builder.call

      mappers = options[:parent] ? readers[parent.name].mappers : {}

      mappers[name] = mapper
      readers[name] = Reader.new(name, parent, mappers) unless options[:parent]

      self
    end

    def respond_to_missing?(name, include_private = false)
      relations.key?(name)
    end

    private

    def method_missing(name)
      relations[name]
    end

  end

end
