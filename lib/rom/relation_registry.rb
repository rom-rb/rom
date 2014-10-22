require 'inflecto'
require 'rom/relation_registry/dsl'

module ROM

  class RelationRegistry
    include Concord.new(:relations, :mappers)

    def self.define(schema, mappers, &block)
      dsl = DSL.new(schema, mappers)
      dsl.instance_exec(&block)
      dsl.call
    end

    def [](name)
      relations.fetch(name)
    end

    def respond_to_missing?(name, include_private = false)
      relations.key?(name)
    end

    private

    def method_missing(name, *args)
      options = args.first || {}
      relation = relations[name]

      if options[:mapper]
        mappers[name].new(relation)
      else
        relation
      end
    end

  end
end
