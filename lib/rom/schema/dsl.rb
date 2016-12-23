require 'dry-equalizer'
require 'rom/types'

module ROM
  # Relation schema
  #
  # @api public
  class Schema
    include Dry::Equalizer(:name, :attributes)
    include Enumerable

    attr_reader :name, :attributes, :inferrer

    # @api public
    class DSL < BasicObject
      attr_reader :relation, :attributes, :inferrer

      # @api private
      def initialize(relation, inferrer, &block)
        @relation = relation
        @inferrer = inferrer
        @attributes = {}

        if block
          instance_exec(&block)
        end
      end

      # Defines a relation attribute with its type
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type)
        @attributes ||= {}
        @attributes[name] = type.meta(name: name, source: relation)
      end

      # Specify which key(s) should be the primary key
      #
      # @api public
      def primary_key(*names)
        names.each do |name|
          attributes[name] = attributes[name].meta(primary_key: true)
        end
        self
      end

      # @api private
      def call
        Schema.define(relation, attributes: attributes.values, inferrer: inferrer)
      end
    end
  end
end
