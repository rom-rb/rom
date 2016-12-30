require 'pathname'

require 'dry/core/inflector'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class CustomNamespace < Base
      option :namespace, reader: true, type: Dry::Types['strict.string']

      def call
        "#{namespace}::#{Dry::Core::Inflector.camelize(filename)}"
      end

      private

      def filename
        Pathname(file).basename('.rb')
      end
    end
  end
end
