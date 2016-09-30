module ROM
  module AutoRegistrationStrategies
    class Base
      include Options

      option :file, reader: true, type: String

      EXTENSION_REGEX = /\.rb$/.freeze
    end
  end
end
