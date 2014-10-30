require 'addressable/uri'

require 'rom/adapter/memory'
require 'rom/adapter/sequel'

module ROM

  class Adapter
    attr_reader :uri

    def self.setup(uri_string)
      uri = Addressable::URI.parse(uri_string)

      adapter =
        case uri.scheme
        when 'sqlite', 'jdbc' then Adapter::Sequel
        when 'memory' then Adapter::Memory
        else
          raise ArgumentError, "#{uri_string.inspect} uri is not supported"
        end

      adapter.new(uri)
    end


    def initialize(uri)
      @uri = uri
    end

    def connection
      raise NotImplemented, "#{self.class}#connection must be implemented"
    end

    def schema
      []
    end

  end

end
