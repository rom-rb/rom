# encoding: utf-8

module ROM

  # Schema builder DSL
  #
  class Schema
    include Concord.new(:definition)
    include Adamantium

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
    def self.build(&block)
      new(Definition.new(&block))
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

    # Iterate over repositories and relations
    #
    # @return [Schema]
    #
    # @api private
    def each(&block)
      definition.repositories.each(&block)
      self
    end

  end # Schema

end # ROM
