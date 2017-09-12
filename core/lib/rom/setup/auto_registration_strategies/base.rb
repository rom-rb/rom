require 'rom/types'
require 'rom/initializer'

module ROM
  module AutoRegistrationStrategies
    # Base class for registration strategies
    #
    # @api private
    class Base
      extend Initializer

      PathnameType = Types.Definition(Pathname).constrained(type: Pathname)

      EXTENSION_REGEX = /\.rb\z/

      # @!attribute [r] file
      #   @return [String] Name of a component file
      option :file, type: Types::Strict::String
    end
  end
end
