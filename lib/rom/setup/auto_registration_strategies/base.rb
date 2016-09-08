module ROM
  module AutoRegistrationStrategies
    class Base
      EXTENSION_REGEX = /\.rb$/.freeze

      include Options
      option :file, reader: true, type: String
    end
  end
end
