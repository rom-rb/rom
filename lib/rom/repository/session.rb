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

    def create(changeset)
      queue[:create] << changeset
      self
    end

    def update(changeset)
      queue[:update] << changeset
      self
    end

    def delete(relation)
      queue[:delete] << relation
      self
    end

    def associate(changeset, assoc)
      queue[:create] << [changeset, assoc]
      self
    end

    def commit!
      delete_commands = map_commands(:delete)
      update_commands = reduce_commands(:update)
      create_commands = reduce_commands(:create)

      delete_commands.each(&:call)
      update_commands.call if update_commands
      create_commands.call if create_commands

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

    def create_command(type, relation, opts = EMPTY_HASH)
      repo.command(type, relation, opts.merge(mapper: false))
    end

    def create_assoc_command(type, relation, name)
      create_command(type, relation, use: { associates: proc { associates(name) }})
    end

    def map_commands(type)
      queue[type].map { |relation| create_command(type, relation).new(relation) }
    end

    def reduce_commands(type)
      queue[type].map do |(changeset, assoc)|
        if assoc
          create_assoc_command(type, changeset.relation, assoc)
        else
          create_command(type, changeset.relation)
        end.curry(changeset)
      end.reduce(:>>)
    end

    def initialize_queue!
      @queue = Hash.new { |h, k| h[k] = [] }
    end
  end
end
