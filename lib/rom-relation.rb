# encoding: utf-8

require 'addressable/uri'

require 'set'
require 'concord'
require 'abstract_type'
require 'descendants_tracker'
require 'equalizer'
require 'axiom'
require 'axiom-optimizer'
require 'charlatan'

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

require 'rom/support/axiom/adapter'

require 'rom/repository'
require 'rom/environment'
require 'rom/relation'

require 'rom/schema'
require 'rom/schema/definition'
require 'rom/schema/definition/relation'
require 'rom/schema/definition/relation/base'

require 'rom/mapping'
require 'rom/mapping/definition'
