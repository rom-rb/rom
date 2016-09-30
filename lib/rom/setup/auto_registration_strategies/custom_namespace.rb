require 'pathname'

require 'rom/support/inflector'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class CustomNamespace < Base
      option :namespace, reader: true, type: String

      def call
        "#{namespace}::#{Inflector.camelize(filename)}"
      end

      private

      def filename
        Pathname(file).basename('.rb')
      end
    end
  end
end
