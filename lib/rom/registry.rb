module ROM
  # @api private
  class Registry
    include Enumerable
    include Dry::Equalizer(:elements)

    class ElementNotFoundError < KeyError
      def initialize(key, name)
        super("#{key.inspect} doesn't exist in #{name} registry")
      end
    end

    attr_reader :elements, :name

    def initialize(elements = {}, name = self.class.name)
      @elements = elements
      @name = name
    end

    def each(&block)
      return to_enum unless block
      elements.each { |element| yield(element) }
    end

    def key?(name)
      elements.key?(name.to_sym)
    end

    def fetch(key)
      elements.fetch(key.to_sym) do
        return yield if block_given?

        raise ElementNotFoundError.new(key, name)
      end
    end
    alias_method :[], :fetch

    def respond_to_missing?(name, include_private = false)
      elements.key?(name) || super
    end

    private

    def method_missing(name, *)
      elements.fetch(name) { super }
    end
  end
end
