require 'pathname'

require 'dry/core/inflector'
require 'rom/types'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class NoNamespace < Base
      option :directory, reader: true, type: PathnameType
      option :entity, reader: true, type: Types::Strict::Symbol

      def call
        Dry::Core::Inflector.camelize(
          file.sub(/^#{directory}\/#{entity}\//, '').sub(EXTENSION_REGEX, '')
        )
      end
    end
  end
end
