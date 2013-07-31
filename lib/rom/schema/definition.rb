# encoding: utf-8

module ROM
  class Schema

    # Builder object used by schema DSL to establish Axiom relations
    #
    # @private
    class Definition
      include Equalizer.new(:relations)

      attr_reader :relations, :repositories

      # @api private
      def initialize(&block)
        @relations    = {}
        @repositories = {}
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
      # @api public
      def base_relation(name, &block)
        base            = Relation::Base.new(&block)
        relation        = Axiom::Relation::Base.new(name, base.header)
        relations[name] = relation

        (repositories[base.repository] ||= []) << relation

        self
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
      # @api public
      def relation(name, &block)
        relations[name] = instance_eval(&block)
        self
      end

      # Return relation identified by name
      #
      # @return [Axiom::Relation, Axiom::Relation::Base]
      #
      # @api private
      def [](name)
        relations[name]
      end

      # Return if the definition object respond to the given method name
      #
      # @return [Boolean]
      #
      # @api private
      def respond_to?(name)
        super || relations.key?(name)
      end

      private

      # Method missing hook
      #
      # @return [Axiom::Relation, Axiom::Relation::Base]
      #
      # @api private
      def method_missing(name, *)
        return super unless relations.key?(name)
        relations[name]
      end

    end # Definition

  end # Schema
end # ROM
