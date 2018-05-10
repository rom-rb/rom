require 'pathname'

require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    # WithNamespace strategy assumes components are defined within a namespace
    # that matches top-level directory name.
    #
    # @api private
    class WithNamespace < Base
      # @!attribute [r] directory
      #   @return [Pathname] The path to dir with components
      option :directory, type: PathnameType

      # Load components
      #
      # @api private
      def call
        ROM.inflector.camelize(
          file.sub(/^#{directory.dirname}\//, '').sub(EXTENSION_REGEX, '')
        )
      end
    end
  end
end
