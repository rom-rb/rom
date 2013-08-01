# encoding: utf-8

module ROM

  # Builder DSL for ROM relations
  #
  class Mapping
    include Adamantium::Flat

    attr_reader :environment, :schema, :model
    private :environment, :schema, :model

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
    # @param [Environment] rom environment
    # @param [Schema] rom schema
    #
    # @return [Hash]
    #
    # @api public
    def self.build(environment, schema = environment.schema, &block)
      new(environment, schema, &block)
    end

    # Initialize a new mapping instance
    #
    # @return [undefined]
    #
    # @api private
    def initialize(environment, schema, &block)
      @environment = environment
      @schema      = schema
      instance_eval(&block)
    end

    private

    # Method missing hook
    #
    # @return [Relation]
    #
    # @api private
    def method_missing(name, *, &block)
      relation = schema[name]

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
      definition = Definition.build(relation.header, &block)
      environment.register(relation.name, Relation.build(relation, definition.mapper))
    end

  end # Mapping

end # ROM
