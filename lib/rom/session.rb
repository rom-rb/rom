# encoding: utf-8

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

  # Session with IdentityMap and state-tracking functionality
  #
  # @example
  #
  #   env.session do |session|
  #     user = session[:users].new(id: 1, name: 'Jane')
  #
  #     session[:users].save(user)
  #
  #     session.flush
  #   end
  #
  # @api public
  class Session
    include Concord.new(:environment)

    # Raised when an object is expected to be tracked and it's not
    #
    class ObjectNotTrackedError < StandardError
      def initialize(identity)
        super("Tracker doesn't include object with identity #{identity.inspect}")
      end
    end

    # Start a new session
    #
    # @example
    #
    #   ROM::Session.start(env) do |session|
    #     user = session[:users].new(name: 'Jane')
    #     session[:users].save(user)
    #     session[:users].flush
    #   end
    #
    # @param [ROM::Environment] rom's environment
    #
    # @yieldparam [Session::Environment]
    #
    # @api public
    def self.start(environment)
      yield(new(Environment.build(environment)))
    end

    # Return a session relation identified by name
    #
    # @param [Symbol] relation name
    #
    # @return [Session::Relation]
    #
    # @api public
    def [](relation_name)
      environment[relation_name]
    end

    # Flush this session committing all the state changes
    #
    # @return [Session]
    #
    # @api public
    def flush
      environment.commit
      self
    end

    # Return if there are any pending state changes
    #
    # @return [Boolean]
    #
    # @api public
    def clean?
      environment.clean?
    end

  end # Session

end # ROM
