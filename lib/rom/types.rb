require 'dry-types'
require 'json'

module ROM
  module Types
    include Dry::Types.module

    def self.included(other)
      other.extend(Methods)
      other::Coercible.extend(CoercibleMethods)
      other::Coercible.const_set('JSON', other::Coercible.JSON)
      other::Coercible.const_set('JSONHash', other::Coercible.JSONHash)
      other::Coercible.const_set('HashJSON', other::Coercible.HashJSON)
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

    module CoercibleMethods
      def JSONHash(symbol_keys: false, type: Types::Hash)
        Types.Constructor(type) do |value|
          next Hash[value] if value.respond_to?(:to_hash)

          begin
            ::JSON.parse(value.to_s, symbolize_names: symbol_keys)
          rescue ::JSON::ParserError
            value
          end
        end
      end

      def HashJSON(type: Types::String)
        Types.Constructor(type) do |value|
          next value unless value.respond_to?(:to_hash)
          ::JSON.dump(value)
        end
      end

      def JSON(symbol_keys: false)
        self.HashJSON.meta(read: self.JSONHash(symbol_keys: symbol_keys))
      end
    end
  end
end
