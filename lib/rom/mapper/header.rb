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
      def self.build(input, options = {})
        return input if input.is_a?(self)

        keys       = options.fetch(:keys, [])
        header     = Axiom::Relation::Header.coerce(input, keys: keys)

        mapping    = options.fetch(:map, {})
        attributes = AttributeSet.coerce(header, mapping)

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
      # @return [Array<Attribute>]
      #
      # @api public
      def keys
        attributes.keys
      end

      # Return attribute with the given name
      #
      # @return [Attribute]
      #
      # @api public
      def [](name)
        attributes[name]
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
