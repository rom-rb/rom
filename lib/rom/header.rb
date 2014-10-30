module ROM

  class Header
    include Enumerable
    include Equalizer.new(:attributes)

    attr_reader :attributes

    class Attribute
      include Equalizer.new(:name, :type)

      attr_reader :name, :meta

      def initialize(name, meta = {})
        @name = name
        @meta = meta
      end

      def type
        meta[:type]
      end
    end

    def self.coerce(attributes)
      new(attributes.map { |pair| pair.is_a?(Attribute) ? pair : Attribute.new(pair[0], type: pair[1]) })
    end

    def initialize(attributes = [])
      @attributes = attributes
    end

    def each(&block)
      return to_enum unless block
      attributes.each(&block)
    end

    def include?(name)
      attributes.map(&:name).include?(name)
    end

    def [](name)
      attributes.detect { |attribute| attribute.name == name }
    end
  end

end
