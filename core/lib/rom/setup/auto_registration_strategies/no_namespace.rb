require 'pathname'

require 'rom/types'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    # NoNamespace strategy assumes components are not defined within a namespace
    #
    # @api private
    class NoNamespace < Base
      # @!attribute [r] directory
      #   @return [Pathname] The path to dir with components
      option :directory, type: PathnameType

      # @!attribute [r] entity
      #   @return [Symbol] Component identifier
      option :entity, type: Types::Strict::Symbol

      # Load components
      #
      # @api private
      def call
        ROM.inflector.camelize(
          file.sub(/^#{directory}\/#{entity}\//, '').sub(EXTENSION_REGEX, '')
        )
      end
    end
  end
end
