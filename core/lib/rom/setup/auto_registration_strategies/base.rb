# frozen_string_literal: true

require 'rom/types'
require 'rom/initializer'

module ROM
  module AutoRegistrationStrategies
    # Base class for registration strategies
    #
    # @api private
    class Base
      extend Initializer

      PathnameType = Types.Instance(Pathname)

      EXTENSION_REGEX = /\.rb\z/

      # @!attribute [r] file
      #   @return [String] Name of a component file
      option :file, type: Types::Strict::String
    end
  end
end
