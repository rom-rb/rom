require 'rom/configuration_dsl'

module ROM
  module ConfigurationPlugins
    # Provides macros for defining relations, mappers and commands
    #
    # @api public
    module ConfigurationDSL

      # @api private
      def self.apply(configuration, options = {})
        configuration.extend(ROM::ConfigurationDSL)
      end
    end
  end
end
