require 'rom/types'
require 'rom/initializer'

module ROM
  module AutoRegistrationStrategies
    class Base
      extend Initializer

      PathnameType = Types.Definition(Pathname).constrained(type: Pathname)

      option :file, type: Types::Strict::String

      EXTENSION_REGEX = /\.rb\z/.freeze
    end
  end
end
