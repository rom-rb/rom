module DataMapper
  class AliasSet
    include Enumerable
    include Adamantium

    def initialize(prefix, attributes = [], excluded = [])
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
      self.class.new(@prefix, @attributes, @excluded.dup.concat(names))
    end

    def merge(other)
      to_hash.merge(other)
    end

    def empty?
      @index.keys.any?
    end

    def to_hash
      @index
    end

    private

    def initialize_index(attributes)
      @index = attributes.each_with_object({}) do |attribute, fields|
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
