# encoding: utf-8

require 'set'
require 'concord'
require 'abstract_type'
require 'descendants_tracker'
require 'equalizer'
require 'charlatan'
require 'addressable/uri'

require 'axiom'
require 'axiom-optimizer'

# Main ROM module with methods to setup and manage the environment
module ROM

  # Raised when the returned tuples are unexpectedly empty
  NoTuplesError = Class.new(RuntimeError)

  # Raised when the returned tuples are unexpectedly too many
  ManyTuplesError = Class.new(RuntimeError)

  # Represent an undefined argument
  Undefined = Class.new.freeze

  # An empty frozen Hash useful for parameter default values
  EMPTY_HASH = {}.freeze

  # An empty frozen Array useful for parameter default values
  EMPTY_ARRAY = [].freeze

  # Represent a positive, infinitely large Float number
  Infinity  = 1.0 / 0

end # module ROM

# axiom additions
require 'rom/support/axiom/adapter'

# relation and schema
require 'rom/repository'
require 'rom/environment'
require 'rom/environment/builder'
require 'rom/relation'

require 'rom/schema'
require 'rom/schema/builder'
require 'rom/schema/definition'
require 'rom/schema/definition/relation'
require 'rom/schema/definition/relation/base'

# mapper
require 'morpher'

require 'rom/mapper/builder'
require 'rom/mapper/builder/definition'
require 'rom/mapper/attribute'
require 'rom/mapper/header'

require 'rom/mapper'

# session
require 'rom/session'

require 'rom/session/environment'
require 'rom/session/tracker'
require 'rom/session/identity_map'
require 'rom/session/relation'
require 'rom/session/mapper'

require 'rom/session/state'
require 'rom/session/state/transient'
require 'rom/session/state/persisted'
require 'rom/session/state/created'
require 'rom/session/state/updated'
require 'rom/session/state/deleted'
