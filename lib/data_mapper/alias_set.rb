module DataMapper
  class AliasSet
    include Enumerable

    attr_reader :prefix
    attr_reader :attributes
    attr_reader :excluded

    # @api private
    def initialize(prefix, attributes = Mapper::AttributeSet.new, excluded = [])
      @prefix     = prefix
      @attributes = attributes
      @excluded   = excluded
      initialize_index(attributes)
    end

    # @api private
    def each(&block)
      return to_enum unless block_given?
      @index.each(&block)
      self
    end

    # @api private
    def exclude(*names)
      self.class.new(prefix, attributes, excluded.dup.concat(names))
    end

    # @api private
    def merge(other)
      attributes = @attributes.merge(other.attributes)
      excluded   = @excluded.dup.concat(other.excluded)
      self.class.new(prefix, attributes, excluded)
    end

    # @api private
    def to_hash
      @index
    end

    private

    # @api private
    def initialize_index(attributes)
      @index = attributes.primitives.each_with_object({}) do |attribute, fields|
        next if excluded?(attribute)
        field = attribute.field
        fields[field] = alias_for(field)
      end
    end

    # @api private
    def excluded?(attribute)
      @excluded.include?(attribute.name)
    end

    # @api private
    def alias_for(field)
      :"#{@prefix}_#{field}"
    end
  end
end
