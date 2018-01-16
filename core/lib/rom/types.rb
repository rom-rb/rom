require 'dry-types'
require 'dry/types/compat/int'
require 'json'

module ROM
  # Default namespace with built-in attribute types
  #
  # @api public
  module Types
    include Dry::Types.module

    # @api private
    def self.included(other)
      other.extend(Methods)
      super
    end

    # Type extensions
    #
    # @api public
    module Methods
      # Shortcut for defining a foreign key attribute type
      #
      # @param [Symbol] relation The name of the target relation
      # @param [Object] type The type of an attribute
      #
      # @return [Dry::Types::Definition]
      #
      # @api public
      def ForeignKey(relation, type = Types::Int)
        type.meta(foreign_key: true, target: relation)
      end
    end

    # Define a json-to-hash attribute type
    #
    # @return [Dry::Types::Constructor]
    #
    # @api public
    def Coercible.JSONHash(symbol_keys: false, type: Types::Hash)
      Types.Constructor(type) do |value|
        begin
          ::JSON.parse(value.to_s, symbolize_names: symbol_keys)
        rescue ::JSON::ParserError
          value
        end
      end
    end

    # Define a hash-to-json attribute type
    #
    # @return [Dry::Types::Constructor]
    #
    # @api public
    def Coercible.HashJSON(type: Types::String)
      Types.Constructor(type) { |value| ::JSON.dump(value) }
    end

    # Define a json type with json-to-hash read type
    #
    # @return [Dry::Types::Constructor]
    #
    # @api public
    def Coercible.JSON(symbol_keys: false)
      self.HashJSON.meta(read: self.JSONHash(symbol_keys: symbol_keys))
    end

    Coercible::JSON = Coercible.JSON
    Coercible::JSONHash = Coercible.JSONHash
    Coercible::HashJSON = Coercible.HashJSON
  end
end
