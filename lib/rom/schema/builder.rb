# encoding: utf-8

require 'rom/schema'
require 'rom/schema/definition'

module ROM
  class Schema

    # Schema builder DSL
    #
    class Builder
      include Concord.new(:repositories)

      attr_reader :relations

      # @api private
      def initialize(repositories)
        super
        @relations = {}
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
        relations.fetch(name)
      end

      # @api private
      def call(&block)
        instance_eval(&block)
        self
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
        definition = Definition::Relation::Base.new(relations, &block)
        repository = repositories.fetch(definition.repository)

        repository[name] = build_relation(name, definition)
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

      # @api private
      def finalize
        Schema.new(relations)
      end

      private

      # @api private
      def build_relation(name, definition)
        header = Axiom::Relation::Header.coerce(definition.header, keys: definition.keys)
        relation = Axiom::Relation::Base.new(name, header)

        definition.wrappings.each { |wrapping| relation = relation.wrap(wrapping) }
        definition.groupings.each { |grouping| relation = relation.group(grouping) }

        relation.rename(definition.renames).optimize
      end

      # @api private
      def method_missing(*args)
        relations[args.first] || super
      end

    end # Builder

  end # Schema
end # ROM
