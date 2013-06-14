module ROM
  class Mapper

    class Header
      include Enumerable, Concord.new(:header, :attributes), Adamantium

      def self.coerce(attributes, options = {})
        header     = Axiom::Relation::Header.coerce(attributes, :keys => options.fetch(:keys, []))
        attributes = AttributeSet.coerce(header, options.fetch(:map, {}))
        new(header, attributes)
      end

      def keys
        attributes.keys
      end

      def each(&block)
        return to_enum unless block_given?
        attributes.each(&block)
        self
      end

    end # Header

  end # Mapper
end # ROM
