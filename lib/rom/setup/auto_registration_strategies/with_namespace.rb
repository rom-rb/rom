require 'pathname'

require 'dry/core/inflector'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class WithNamespace < Base
      option :directory, type: PathnameType

      def call
        Dry::Core::Inflector.camelize(
          file.sub(/^#{directory.dirname}\//, '').sub(EXTENSION_REGEX, '')
        )
      end
    end
  end
end
