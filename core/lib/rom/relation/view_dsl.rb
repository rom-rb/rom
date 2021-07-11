# frozen_string_literal: true

module ROM
  class Relation
    # ViewDSL is exposed in `Relation.view` method
    #
    # This is used to establish pre-defined relation views with explicit schemas.
    # Such views can be used to compose relations together, even from multiple
    # adapters. In advanced adapters like rom-sql using view DSL is not required though,
    # as relation schemas are dynamic and they always represent current tuple structure.
    #
    # @api public
    class ViewDSL
      # @!attribute [r] name
      #   @return [Symbol] The view name (relation method)
      attr_reader :name

      # @!attribute [r] relation_block
      #   @return [Proc] The relation block that will be evaluated by the view method
      attr_reader :relation_block

      # @!attribute [r] new_schema
      #   @return [Proc] The schema proc returned by the schema DSL
      attr_reader :new_schema

      # @api private
      def initialize(name, schema, &block)
        @name = name
        @schema = schema
        @new_schema = nil
        @relation_block = nil
        instance_eval(&block)
      end

      # Define a schema for a relation view
      #
      # @return [Proc]
      #
      # @see Relation::ClassInterface.view
      #
      # @api public
      def schema(&block)
        @new_schema = -> relations { @schema.with(relations: relations).instance_exec(&block) }
      end

      # Define a relation block for a relation view
      #
      # @return [Proc]
      #
      # @see Relation::ClassInterface.view
      #
      # @api public
      def relation(&block)
        @relation_block = proc(&block)
      end

      # Return procs captured by the DSL
      #
      # @return [Array]
      #
      # @api private
      def call
        [name, new_schema, relation_block]
      end
    end
  end
end
