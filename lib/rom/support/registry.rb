module ROM
  # @api private
  class Registry
    include Enumerable
    include Equalizer.new(:elements)

    class ElementNotFoundError < KeyError
      def initialize(key, name)
        super("#{key.inspect} doesn't exist in #{name} registry")
      end
    end

    attr_reader :elements, :name

    def initialize(elements = {})
      @elements = elements
      @name = self.class.name
    end

    def each(&block)
      return to_enum unless block
      elements.each(&block)
    end

    def [](key)
      elements.fetch(key) { raise ElementNotFoundError.new(key, name) }
    end

    def respond_to_missing?(name, include_private = false)
      elements.key?(name) || super
    end

    private

    def method_missing(name, *)
      elements.fetch(name) { super }
    end
  end
end
