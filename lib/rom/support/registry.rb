module ROM

  # @api private
  class Registry
    include Enumerable
    include Equalizer.new(:elements)

    attr_reader :elements

    def initialize(elements = {})
      @elements = elements
    end

    def each(&block)
      return to_enum unless block
      elements.each(&block)
    end

    def [](name)
      elements[name]
    end

    def respond_to_missing?(name, include_private = false)
      key?(name) || super
    end

    private

    def method_missing(name, *args)
      self[name]
    end

  end

end
