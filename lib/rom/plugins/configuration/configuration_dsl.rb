require 'rom/configuration_dsl'
require 'dry/core/deprecations'

module ROM
  module ConfigurationPlugins
    # Provides macros for defining relations, mappers and commands
    #
    # @api public
    module ConfigurationDSL

      # @api private
      def self.apply(configuration, options = {})
        Dry::Core::Deprecations.announce(
          :macros,
          "Calling `use(:macros)` is no longer necessary. Macros are enabled by default.",
          tag: :rom
        )
      end
    end
  end
end
