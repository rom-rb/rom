require 'dry/equalizer'

module ROM
  class Session
    include Dry::Equalizer(:queue, :status)

    attr_reader :repo

    attr_reader :queue

    attr_reader :status

    def initialize(repo)
      @repo = repo
      @status = :pending
      initialize_queue!
    end

    def add(changeset)
      queue << changeset
      self
    end

    def commit!
      queue.map(&:command).compact.each(&:call)

      @status = :success

      self
    rescue => e
      @status = :failure
      raise e
    ensure
      initialize_queue!
    end

    def pending?
      status.equal?(:pending)
    end

    def success?
      status.equal?(:success)
    end

    def failure?
      status.equal?(:failure)
    end

    private

    def initialize_queue!
      @queue = []
    end
  end
end
