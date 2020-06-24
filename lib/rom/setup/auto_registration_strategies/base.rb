# frozen_string_literal: true

require "rom/types"
require "rom/initializer"
require "rom/support/inflector"

module ROM
  module AutoRegistrationStrategies
    # Base class for registration strategies
    #
    # @api private
    class Base
      extend Initializer

      PathnameType = Types.Instance(Pathname)

      EXTENSION_REGEX = /\.rb\z/.freeze

      # @!attribute [r] file
      #   @return [String] Name of a component file
      option :file, type: Types::Strict::String

      # @!attribute [r] inflector
      #   @return [Dry::Inflector] String inflector
      #   @api private
      option :inflector, reader: true, default: -> { Inflector }
    end
  end
end
