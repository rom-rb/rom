require 'equalizer'

require 'rom/version'
require 'rom/constants'

# internal ROM support lib
require 'rom/support/inflector'
require 'rom/support/registry'
require 'rom/support/options'
require 'rom/support/class_macros'
require 'rom/support/class_builder'

# core parts
require 'rom/plugin'
require 'rom/relation'
require 'rom/mapper'
require 'rom/command'

# default mapper processor using Transproc gem
require 'rom/processor/transproc'

# support for global-style setup
require 'rom/global'
require 'rom/setup'

# TODO: consider to make this part optional and don't require it here
require 'rom/setup_dsl/setup'

# env with registries
require 'rom/env'

module ROM
  extend Global

  RelationRegistry = Class.new(Registry)
end

# register core plugins
require 'rom/plugins/relation/registry_reader'

ROM.plugins do
  register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
end
