module ROM
  # Exposes defined repositories, relations and mappers
  #
  # @api public
  class Env
    include Adamantium::Flat
    include Equalizer.new(:repositories, :relations, :readers, :commands)
    include Commands

    attr_reader :repositories, :relations, :readers, :commands

    # @api private
    def initialize(repositories, relations, readers, commands)
      @repositories = repositories
      @relations = relations
      @readers = readers
      @commands = commands
    end

    # @api public
    def try(&block)
      begin
        response = block.call

        if response.kind_of?(Command)
          try { response.call }
        else
          Result::Success.new(response)
        end
      rescue CommandError => e
        Result::Failure.new(e)
      end
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
        reader.instance_eval(&block)
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
