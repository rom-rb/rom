module ROM

  # Extends ROM's environment with IdentityMap and state-tracking functionality
  #
  # @api public
  class Session
    include Concord.new(:environment)

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
      yield(new(Environment.new(environment, Tracker.new)))
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

  end # Session

end # ROM
