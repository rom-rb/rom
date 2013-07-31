module ROM
  class Mapper

    # Mapper header wrapping axiom header and providing mapping information
    #
    # @private
    class Header
      include Enumerable, Concord.new(:header, :attributes), Adamantium

      # Build a header
      #
      # @api private
      def self.build(attributes, options = {})
        header     = Axiom::Relation::Header.coerce(attributes, :keys => options.fetch(:keys, []))
        attributes = AttributeSet.coerce(header, options.fetch(:map, {}))
        new(header, attributes)
      end

      # Return attribute mapping
      #
      # @api private
      def mapping
        attributes.mapping
      end

      # Return all key attributes
      #
      # @api private
      def keys
        attributes.keys
      end

      # Iterate over attributes
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        attributes.each(&block)
        self
      end

    end # Header

  end # Mapper
end # ROM
