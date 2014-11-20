require 'addressable/uri'

module ROM

  class Adapter
    include Equalizer.new(:connection)

    @adapters = []

    attr_reader :uri

    def self.setup(uri_string)
      uri = Addressable::URI.parse(uri_string)

      unless adapter = self[uri.scheme]
        raise ArgumentError, "#{uri_string.inspect} uri is not supported"
      end

      adapter.new(uri)
    end

    def self.register(adapter)
      @adapters.unshift adapter
    end

    def self.[](scheme)
      @adapters.detect { |adapter| adapter.schemes.include?(scheme.to_sym) }
    end

    def initialize(uri)
      @uri = uri
    end

    def connection
      raise NotImplementedError, "#{self.class}#connection must be implemented"
    end

    def extend_relation_class(klass)
      klass
    end

    def extend_relation_instance(relation)
      relation
    end

    def schema
      []
    end

  end

end
