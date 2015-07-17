require 'equalizer'

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
require 'rom/plugin'
require 'rom/relation'
require 'rom/mapper'
require 'rom/commands'

# default mapper processor using Transproc gem
require 'rom/processor/transproc'

# rom environments
require 'rom/environment'

# TODO: consider to make this part optional and don't require it here
require 'rom/setup_dsl/setup'

# env with registries
require 'rom/env'

module ROM
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
end

# register core plugins
require 'rom/plugins/relation/registry_reader'

ROM.plugins do
  register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
end
ROM::Relation.on(:inherited) { |relation| ROM.register_relation(relation) }
ROM::Command.on(:inherited) { |command| ROM.register_command(command) }
ROM::Mapper.on(:inherited) { |mapper| ROM.register_mapper(mapper) }
