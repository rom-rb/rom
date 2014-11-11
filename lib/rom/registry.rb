module ROM

  class Registry
    attr_reader :elements

    def initialize
      @elements = {}
    end

    def each(&block)
      return to_enum unless block
      elements.each(&block)
    end

    def [](name)
      elements[name]
    end

    def <<(element)
      self[element.name] = element
    end

    def []=(name, element)
      elements[name] = element
    end

    def respond_to_missing?(name, include_private = false)
      elements.key?(name) || super
    end

    private

    def method_missing(name, *args)
      self[name]
    end

  end

end
