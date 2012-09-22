module DataMapper
  class Mapper
    # Attribute
    #
    # @api private
    class Attribute

      # @api private
      attr_reader :name

      # @api private
      attr_reader :type

      # @api private
      attr_reader :field

      PRIMITIVES = Veritas::Attribute.descendants.map(&:primitive).freeze

      # @api public
      def self.build(name, options = {})
        klass = if PRIMITIVES.include?(options[:type])
            Attribute::Primitive
          elsif options[:collection]
            Attribute::EmbeddedCollection
          else
            Attribute::EmbeddedValue
          end

        klass.new(name, options)
      end

      # @api private
      def initialize(name, options = {})
        @name  = name
        @field = options.fetch(:to, @name)
        @key   = options.fetch(:key, false)
      end

      # @api public
      def finalize
        # noop
      end

      # @api private
      #
      def load(tuple)
        raise NotImplementedError, "#{self.class} must implement #load"
      end

      # @api private
      def key?
        @key
      end

      # @api private
      def primitive?
        false
      end

    end # class Attribute
  end # class Mapper
end # module DataMapper
