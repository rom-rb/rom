module ROM
  # Exposes defined repositories, schema, relations and mappers
  #
  # @api public
  class Env
    include Adamantium::Flat
    include Equalizer.new(
      :repositories, :schema, :relations, :mappers, :commands
    )

    attr_reader :repositories, :schema, :relations, :mappers, :commands

    # @api private
    def initialize(repositories, schema, relations, mappers, commands)
      @repositories = repositories
      @schema = schema
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

    # @api private
    def [](name)
      repositories.fetch(name)
    end

    # @api private
    def respond_to_missing?(name, include_private = false)
      repositories.key?(name) || super
    end

    private

    # @api private
    def method_missing(name, *args, &block)
      if repositories.key?(name)
        repositories[name]
      else
        super
      end
    end
  end
end
