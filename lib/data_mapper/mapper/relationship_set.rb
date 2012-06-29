module DataMapper
  class Mapper

    # relationshipset
    #
    # @api private
    class RelationshipSet
      include Enumerable

      # @api private
      def initialize
        @relationships = {}
      end

      # @api public
      def each
        return to_enum unless block_given?
        @relationships.each_value { |attribute| yield attribute }
        self
      end

      # @api private
      def header
        @header ||= map(&:header)
      end

      # @api private
      def add(name, options = {})
        @relationships[name] = options[:type].new(name, options)
        self
      end

      # @api private
      def [](name)
        @relationships[name]
      end

      # @api private
      def key
        map(&:key?)
      end

    end # class relationshipset
  end # class Mapper
end # module DataMapper
