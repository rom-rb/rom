module ROM
  # Exposes defined repositories, relations and mappers
  #
  # @api public
  class Env
    include Equalizer.new(:repositories, :relations, :readers, :commands)

    # @return [Hash] configured repositories
    #
    # @api public
    attr_reader :repositories

    # @return [RelationRegistry] relation registry
    #
    # @api public
    attr_reader :relations

    # @return [ReaderRegistry] reader registry
    #
    # @api public
    attr_reader :readers

    # @return [Registry] command registry
    #
    # @api public
    attr_reader :commands

    # @api private
    def initialize(repositories, relations, readers, commands)
      @repositories = repositories
      @relations = relations
      @readers = readers
      @commands = commands
      freeze
    end

    # Returns a reader with access to defined mappers
    #
    # @example
    #
    #   # with a mapper derived from relation access path "users.adults"
    #   rom.read(:users).adults.to_a
    #
    #   # or with explicit mapper name
    #   rom.read(:users).with(:some_mapper).to_a
    #
    # @param [Symbol] name of the registered reader
    # @param [Hash] option hash
    #
    # @api public
    def read(name, &block)
      reader = readers[name]

      if block
        yield(reader)
      else
        reader
      end
    end

    # Returns commands registry for the given relation
    #
    # @example
    #
    #   rom.command(:users).create
    #
    # @api public
    def command(name)
      commands[name]
    end
  end
end
