require 'pathname'

require 'rom/support/inflector'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class WithNamespace < Base
      option :directory, reader: true, type: Pathname

      def call
        Inflector.camelize(
          file.sub(/^#{directory.dirname}\//, '').sub(EXTENSION_REGEX, '')
        )
      end
    end
  end
end
