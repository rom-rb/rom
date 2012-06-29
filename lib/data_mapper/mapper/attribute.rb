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

      # @api private
      def initialize(name, options = {})
        @name  = name
        @field = options.fetch(:to, @name)
        @type  = options.fetch(:type, Object)
        @key   = options.fetch(:key, false)
      end

      # @api public
      def finalize
        @mapper = DataMapper[type]
      end

      # @api private
      def load(tuple)
        if @mapper
          @mapper.load(tuple)
        else
          tuple[field]
        end
      end

      # @api private
      def header
        [ @field, @type ]
      end

      # @api private
      def primitive?
        PRIMITIVES.include?(type)
      end

      # @api private
      def key?
        @key
      end

    end # class Attribute
  end # class Mapper
end # module DataMapper
