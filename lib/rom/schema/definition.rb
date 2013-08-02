# encoding: utf-8

module ROM
  class Schema

    # Builder object used by schema DSL to establish Axiom relations
    #
    # @private
    class Definition
      include Equalizer.new(:repositories, :relations)

      attr_reader :repositories, :relations

      # @api private
      def initialize(repositories, &block)
        @repositories = repositories
        @relations    = {}
        instance_eval(&block) if block
      end

      # Build a base relation
      #
      # @example
      #
      #   Schema.build do
      #     base_relation :users do
      #       # ...
      #     end
      #   end
      #
      # @return [Definition]
      #
      # @api private
      def base_relation(name, &block)
        builder    = Relation::Base.new(&block)
        repository = repositories.fetch(builder.repository)

        repository[name] = builder.call(name)
        relations[name]  = repository[name]
      end

      # Build a relation
      #
      # @example
      #
      #   Schema.build do
      #     relation :users do
      #       # ...
      #     end
      #   end
      #
      # @return [Definition]
      #
      # @api private
      def relation(name, &block)
        relations[name] = instance_eval(&block)
      end

      # Return relation identified by name
      #
      # @return [Axiom::Relation, Axiom::Relation::Base]
      #
      # @api private
      def [](name)
        relations[name]
      end

      private

      # Method missing hook
      #
      # @return [Axiom::Relation, Axiom::Relation::Base]
      #
      # @api private
      def method_missing(name)
        self[name] || super
      end

    end # Definition

  end # Schema
end # ROM
