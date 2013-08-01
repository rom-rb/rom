# encoding: utf-8

module ROM

  # Schema builder DSL
  #
  class Schema
    include Concord.new(:definition), Adamantium::Flat

    # Build a relation schema
    #
    # @example
    #
    #   Schema.build do
    #     base_relation :users do
    #       repository :test
    #       attribute :id, :name
    #     end
    #   end
    #
    # @return [Schema]
    #
    # @api public
    def self.build(repositories, &block)
      new(Definition.new(repositories, &block))
    end

    # Return defined relation identified by name
    #
    # @example
    #
    #   schema[:users] # => #<Axiom::Relation::Base ..>
    #
    # @return [Axiom::Relation, Axiom::Relation::Base]
    #
    # @api public
    def [](name)
      definition[name]
    end

    # @api private
    def call(&block)
      definition.instance_eval(&block)
    end

  end # Schema

end # ROM
