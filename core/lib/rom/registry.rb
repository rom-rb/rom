require 'dry/equalizer'
require 'dry/core/cache'

require 'rom/initializer'
require 'rom/constants'

module ROM
  # @api private
  class Registry
    include Enumerable
    include Dry::Equalizer(:elements)

    attr_reader :elements

    def self.element_not_found_error
      ElementNotFoundError
    end

    def initialize(elements = {})
      @elements = elements
    end

    def each(&block)
      return to_enum unless block
      elements.each { |element| yield(element) }
    end

    def key?(name)
      !name.nil? && elements.key?(name.to_sym)
    end

    def fetch(key)
      raise ArgumentError.new('key cannot be nil') if key.nil?

      elements.fetch(key.to_sym) do
        return yield if block_given?

        raise self.class.element_not_found_error.new(key, self)
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
