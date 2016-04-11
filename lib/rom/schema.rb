require 'dry-equalizer'
require 'rom/types'

module ROM
  # Relation schema
  #
  # @api public
  class Schema
    include Dry::Equalizer(:dataset, :attributes, :meta)
    include Enumerable

    attr_reader :dataset, :attributes, :meta

    # @api public
    class DSL < BasicObject
      attr_reader :dataset, :attributes

      # @api private
      def initialize(dataset = nil, &block)
        @attributes = {}
        @dataset = dataset
        instance_exec(&block)
      end

      # Defines a relation attribute with its type
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type)
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
        Schema.new(dataset, attributes)
      end
    end

    # @api private
    def initialize(dataset, attributes)
      @dataset = dataset
      @attributes = attributes
      freeze
    end

    # Return attribute
    #
    # @api public
    def [](name)
      attributes.fetch(name)
    end

    # @api public
    def primary_key
      attributes.values.select do |attr|
        attr.meta[:primary_key] == true
      end
    end

    # Iterate over schema's attributes
    #
    # @yield [Dry::Data::Type]
    #
    # @api public
    def each(&block)
      attributes.each(&block)
    end
  end
end
