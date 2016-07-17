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
      attr_reader :name, :attributes, :inferrer

      # @api private
      def initialize(name, inferrer, &block)
        @name = name
        @inferrer = inferrer
        @attributes = nil

        if block
          instance_exec(&block)
        elsif inferrer.nil?
          raise ArgumentError,
            'You must pass a block to define a schema or set an inferrer for automatic inferring'
        end
      end

      # Defines a relation attribute with its type
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type)
        @attributes ||= {}
        @attributes[name] = type.meta(name: name)
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
        Schema.new(name, attributes, inferrer: inferrer && inferrer.new(self))
      end
    end
  end
end
