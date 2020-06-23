# frozen_string_literal: true

require "dry/equalizer"

module ROM
  # TODO: finish this in 1.1.0
  #
  # @api private
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
      queue.each(&:commit)

      @status = :success

      self
    rescue StandardError => e
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
