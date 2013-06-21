require 'adamantium'
require 'equalizer'
require 'abstract_type'
require 'concord'

require 'rom-relation'
require 'rom-mapper'

module ROM

  # Session namespace
  class Session

  end # Session

end # ROM

require 'rom/session'

require 'rom/session/tracker'
require 'rom/session/state'
require 'rom/session/identity_map'
require 'rom/session/relation'
require 'rom/session/mapper'
require 'rom/session/registry'
