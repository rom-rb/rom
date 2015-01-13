module ROM
  # Exposes defined repositories, schema, relations and mappers
  #
  # @api public
  class Env
    include Adamantium::Flat
    include Equalizer.new(:repositories, :relations, :mappers, :commands)

    attr_reader :repositories, :relations, :mappers, :commands

    # @api private
    def initialize(repositories, relations, mappers, commands)
      @repositories = repositories
      @relations = relations
      @mappers = mappers
      @commands = commands
    end

    # Returns a reader with access to defined mappers
    #
    # @example
    #
    #   rom.read(:users).adults.to_a
    #
    # @api public
    def read(name)
      mappers[name]
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

    # Return repository identified by its name
    #
    # @return [Repository]
    #
    # @api private
    def [](name)
      repositories.fetch(name)
    end

    # @api private
    def respond_to_missing?(name, include_private = false)
      repositories.key?(name) || super
    end

    private

    # Return repository if the method matches repository name
    #
    # @return [Repository]
    #
    # @api private
    def method_missing(name, *)
      repositories.fetch(name) { super }
    end
  end
end
