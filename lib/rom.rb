require 'equalizer'

require 'rom-support'
require 'rom/version'
require 'rom/constants'

# internal ROM support lib
require 'rom/support/inflector'
require 'rom/support/registry'
require 'rom/support/options'
require 'rom/support/class_macros'
require 'rom/support/class_builder'
require 'rom/support/guarded_inheritance_hook'
require 'rom/support/inheritance_hook'

# core parts
require 'rom/environment_plugin'
require 'rom/plugin'
require 'rom/relation'
require 'rom-mapper'
require 'rom/commands'

# rom Global
require 'rom/global'

# rom environments
require 'rom/environment'

# TODO: consider to make this part optional and don't require it here
require 'rom/setup_dsl/setup'

# container with registries
require 'rom/container'

# register core plugins
require 'rom/environment_plugins/auto_registration'
require 'rom/plugins/relation/registry_reader'

module ROM
  extend Global

  @environment = ROM::Environment.new

  class << self
    def method_missing(method, *args, &block)
      if @environment.respond_to?(method)
        @environment.__send__(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, _include_private = false)
      @environment.respond_to?(method) || super
    end
  end

  plugins do
    register :auto_registration, ROM::EnvironmentPlugins::AutoRegistration, type: :environment
    register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
  end
end
