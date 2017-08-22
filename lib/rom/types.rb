require 'dry-types'
require 'json'

module ROM
  module Types
    include Dry::Types.module

    def self.included(other)
      other.extend(Methods)
      super
    end

    def self.Definition(primitive)
      Dry::Types::Definition.new(primitive)
    end

    def self.Constructor(primitive, &block)
      Types.Definition(primitive).constructor(&block)
    end

    module Methods
      def ForeignKey(relation, type = Types::Int)
        type.meta(foreign_key: true, target: relation)
      end
    end

    def Coercible.JSONHash(symbol_keys: false, type: Types::Hash)
      Types.Constructor(type) do |value|
        begin
          ::JSON.parse(value.to_s, symbolize_names: symbol_keys)
        rescue ::JSON::ParserError
          value
        end
      end
    end

    def Coercible.HashJSON(type: Types::String)
      Types.Constructor(type) { |value| ::JSON.dump(value) }
    end

    def Coercible.JSON(symbol_keys: false)
      self.HashJSON.meta(read: self.JSONHash(symbol_keys: symbol_keys))
    end

    Coercible::JSON = Coercible.JSON
    Coercible::JSONHash = Coercible.JSONHash
    Coercible::HashJSON = Coercible.HashJSON
  end
end
