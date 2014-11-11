require 'inflecto'
require 'rom/relation_registry/dsl'

module ROM

  class RelationRegistry
    include Concord.new(:relations)

    def self.define(schema, &block)
      dsl = DSL.new(schema)
      dsl.instance_exec(&block)
      dsl.call
    end

    def [](name)
      relations.fetch(name)
    end

    def key?(name)
      relations.key?(name)
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
