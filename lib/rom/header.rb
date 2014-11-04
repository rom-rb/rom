module ROM

  class Header
    include Enumerable
    include Equalizer.new(:attributes)

    attr_reader :attributes

    class Attribute
      include Equalizer.new(:name, :type)

      attr_reader :name, :meta

      def self.coerce(input)
        if input.kind_of?(self)
          input
        else
          new(input[0], input[1])
        end
      end

      def initialize(name, meta = {})
        @name = name
        @meta = meta
      end

      def type
        meta[:type]
      end
    end

    def self.coerce(input)
      if input.kind_of?(self)
        input
      else
        attributes = input.each_with_object({}) { |pair, h|
          h[pair.first] = Attribute.coerce(pair)
        }

        new(attributes)
      end
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def each(&block)
      return to_enum unless block
      attributes.values.each(&block)
    end

    def keys
      attributes.keys
    end

    def values
      attributes.values
    end

    def [](name)
      attributes.fetch(name)
    end

    def respond_to_missing?(name, include_private = false)
      attributes.key?(name)
    end

    private

    def method_missing(name)
      attributes[name]
    end
  end

end
