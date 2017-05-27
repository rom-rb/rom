require 'dry-equalizer'
require 'rom/types'

module ROM
  # Relation schema
  #
  # @api public
  class Schema
    AttributeAlreadyDefinedError = Class.new(StandardError)

    include Dry::Equalizer(:name, :attributes)
    include Enumerable

    attr_reader :name, :attributes, :inferrer

    # @api public
    class DSL < BasicObject
      attr_reader :relation, :attributes, :inferrer, :schema_class

      # @api private
      def initialize(relation, schema_class: Schema, inferrer: Schema::DEFAULT_INFERRER, &block)
        @relation = relation
        @inferrer = inferrer
        @schema_class = schema_class
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
      def attribute(name, type, options = EMPTY_HASH)
        if @attributes.key?(name)
          ::Kernel.raise ::ROM::Schema::AttributeAlreadyDefinedError,
                         "Attribute #{ name.inspect } already defined"
        end

        @attributes[name] =
          if options[:read]
            type.meta(name: name, source: relation, read: options[:read])
          else
            type.meta(name: name, source: relation)
          end
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
        schema_class.define(relation, attributes: attributes.values, inferrer: inferrer)
      end
    end
  end
end
