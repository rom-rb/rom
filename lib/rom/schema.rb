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

    # @api private
    def initialize(name, attributes, inferrer: nil)
      @name = name
      @attributes = attributes
      @inferrer = inferrer

      freeze if self.defined?
    end

    # Iterate over schema's attributes
    #
    # @yield [Dry::Data::Type]
    #
    # @api public
    def each(&block)
      attributes.each_value(&block)
    end

    # Return attribute
    #
    # @api public
    def [](name)
      attributes.fetch(name)
    end

    # @api public
    def primary_key
      select { |attr| attr.meta[:primary_key] == true }
    end

    # @api public
    def foreign_key(relation)
      detect { |attr| attr.meta[:foreign_key] && attr.meta[:relation] == relation }
    end

    # @api public
    def defined?
      !@attributes.nil?
    end

    # @api private
    def infer!(gateway)
      @attributes = inferrer.call(name.dataset, gateway)
      freeze
    end
  end
end
