module DataMapper
  class AliasSet
    include Enumerable

    attr_reader :prefix

    attr_reader :attributes

    attr_reader :excluded

    def initialize(prefix, attributes = Mapper::AttributeSet.new, excluded = [])
      @prefix     = prefix
      @attributes = attributes
      @excluded   = excluded
      initialize_index(attributes)
    end

    def each(&block)
      return to_enum unless block_given?
      @index.each { |field, alias_name| yield(field, alias_name) }
      self
    end

    def exclude(*names)
      self.class.new(prefix, attributes, excluded.dup.concat(names))
    end

    def merge(other)
      attributes = @attributes.merge(other.attributes)
      excluded   = @excluded.dup.concat(other.excluded)
      self.class.new(prefix, attributes, excluded)
    end

    def to_hash
      @index
    end

    private

    def initialize_index(attributes)
      @index = attributes.primitives.each_with_object({}) do |attribute, fields|
        next if excluded?(attribute)
        field = attribute.field
        fields[field] = alias_for(field)
      end
    end

    def excluded?(attribute)
      @excluded.include?(attribute.name)
    end

    def alias_for(field)
      :"#{@prefix}_#{field}"
    end
  end
end
