require 'descendants_tracker'
require 'concord'
require 'charlatan'
require 'inflecto'

require 'rom/version'
require 'rom/constants'

# internal ROM support lib
require 'rom/support/registry'
require 'rom/support/options'
require 'rom/support/class_macros'
require 'rom/support/class_builder'

# core parts
require 'rom/relation'
require 'rom/mapper'
require 'rom/reader'
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
  ReaderRegistry = Class.new(Registry)
end
