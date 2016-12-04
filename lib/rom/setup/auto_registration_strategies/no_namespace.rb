require 'pathname'

require 'dry/core/inflector'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class NoNamespace < Base
      option :directory, reader: true, type: Pathname
      option :entity, reader: true, type: Symbol

      def call
        Dry::Core::Inflector.camelize(
          file.sub(/^#{directory}\/#{entity}\//, '').sub(EXTENSION_REGEX, '')
        )
      end
    end
  end
end
