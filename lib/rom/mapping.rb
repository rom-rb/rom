# encoding: utf-8

module ROM

  # Builder DSL for ROM relations
  #
  class Mapping

    attr_reader :env, :registry, :model
    private :env, :model

    # Build ROM relations
    #
    # @example
    #   relation = Axiom::Relation::Base.new(:users, [[:id, Integer], [:user_name, String]])
    #   env      = { users: relation }
    #
    #   User = Class.new(OpenStruct.new)
    #
    #   registry = Mapping.build(env) do
    #     users do
    #       map :id
    #       map :user_name, to: :name
    #     end
    #   end
    #
    #   registry[:users]
    #   # #<ROM::Relation:0x000000025d3160>
    #
    # @param [Environment, Hash] container with configured axiom relations
    # @param [Hash] registry for rom relations
    #
    # @return [Hash]
    #
    # @api public
    def self.build(env, registry = {}, &block)
      new(env, registry, &block).registry
    end

    # Initialize a new mapping instance
    #
    # @return [undefined]
    #
    # @api private
    def initialize(env, registry, &block)
      @env      = env
      @registry = registry
      instance_eval(&block)
    end

    private

    # Method missing hook
    #
    # @return [Relation]
    #
    # @api private
    def method_missing(name, *args, &block)
      relation = env[name]

      if relation
        build_relation(relation, &block)
      else
        super
      end
    end

    # Build relation
    #
    # @return [Relation]
    #
    # @api private
    def build_relation(relation, &block)
      definition              = Definition.build(relation.header, &block)
      registry[relation.name] = Relation.build(relation, definition.mapper)
    end

  end # Mapping

end # ROM
