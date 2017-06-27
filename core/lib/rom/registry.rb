require 'dry/equalizer'

require 'rom/initializer'
require 'rom/cache'
require 'rom/constants'

module ROM
  # @api private
  class Registry
    extend Initializer

    include Enumerable
    include Dry::Equalizer(:elements)

    param :elements

    option :cache, reader: true, default: -> { Cache.new }

    def self.new(*args)
      case args.size
      when 0
        super({}, {})
      when 1
        super(*args, {})
      else
        super(*args)
      end
    end

    def self.element_not_found_error
      ElementNotFoundError
    end

    def map(&block)
      new_elements = elements.each_with_object({}) do |(name, element), h|
        h[name] = yield(element)
      end
      self.class.new(new_elements, options)
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
