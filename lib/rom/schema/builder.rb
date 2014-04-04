# encoding: utf-8

module ROM
  class Schema

    # Schema builder DSL
    #
    class Builder
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
        self
      end

      # @api private
      def finalize
        Schema.new(definition.relations)
      end

    end # Builder

  end # Schema
end # ROM
