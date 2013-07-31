# encoding: utf-8

module ROM

  class Mapping

    attr_reader :env, :registry, :model

    # @api public
    def self.build(env, &block)
      new(env, &block).registry
    end

    # @api private
    def initialize(env, &block)
      @env      = env
      @registry = {}
      instance_eval(&block)
    end

    private

    # @api private
    def method_missing(name, *args, &block)
      relation = env[name]

      if relation
        build_relation(relation, &block)
      else
        super
      end
    end

    # @api private
    def build_relation(relation, &block)
      definition = Definition.build(relation.header, &block)
      mapper     = definition.mapper || Mapper.build(definition.header, definition.model)

      registry[relation.name] = Relation.build(relation, mapper)
    end

  end # Mapping

end # ROM
