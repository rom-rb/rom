module ROM
  # Exposes defined repositories, relations and mappers
  #
  # @api public
  class Env
    include Adamantium::Flat
    include Equalizer.new(:repositories, :relations, :readers, :commands)

    attr_reader :repositories, :relations, :readers, :commands

    # @api private
    def initialize(repositories, relations, readers, commands)
      @repositories = repositories
      @relations = relations
      @readers = readers
      @commands = commands
    end

    # Returns a reader with access to defined mappers
    #
    # @example
    #
    #   # with a mapper derived from relation access path "users.adults"
    #   rom.read(:users).adults.to_a
    #
    #   # or with explicit mapper name
    #   rom.read(:users, mapper: :some_mapper).to_a
    #
    # @param [Symbol] name of the registered reader
    # @param [Hash] option hash
    #
    # @api public
    def read(name, options = {})
      reader = readers[name]
      mapper = options[:mapper]

      if mapper
        reader.with_mapper(mapper)
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
