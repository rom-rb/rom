# encoding: utf-8

require 'adamantium'
require 'equalizer'
require 'abstract_type'
require 'concord'

require 'rom-relation'
require 'rom-mapper'

module ROM

  # Extended ROM::Environment with session support
  class Environment

    # Start a new session for this environment
    #
    # @example
    #  env.session do |session|
    #    # ...
    #  end
    #
    # @see Session.start
    #
    # @api public
    def session(&block)
      Session.start(self, &block)
    end
  end

  # Session namespace
  class Session

    # Raised when an object is expected to be tracked and it's not
    #
    class ObjectNotTrackedError < StandardError
      def initialize(object)
        super("Tracker doesn't include #{object.inspect}")
      end
    end

  end # Session

end # ROM

require 'rom/support/proxy'

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
