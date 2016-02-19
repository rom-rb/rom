require 'rom/configuration_dsl'
require 'rom/support/deprecations'

module ROM
  module ConfigurationPlugins
    # Provides macros for defining relations, mappers and commands
    #
    # @api public
    module ConfigurationDSL

      # @api private
      def self.apply(configuration, options = {})
        ROM::Deprecations.announce(:macros, "Calling `use(:macros)` is no longer necessary. Macros are enabled by default.")
      end
    end
  end
end
