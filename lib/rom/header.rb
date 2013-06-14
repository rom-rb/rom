module ROM

  class Header
    include Enumerable, Concord.new(:header, :mapping)

    def self.coerce(attributes, mapping = {})
      new(Axiom::Relation::Header.coerce(attributes), mapping)
    end

    def each(&block)
      return to_enum unless block_given?

      header.each do |attribute|
        yield(attribute, mapping.fetch(attribute.name) { attribute.name })
      end

      self
    end

  end # Header

end # ROM
