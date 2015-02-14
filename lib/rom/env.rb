require 'rom/relation/loaded'

module ROM
  # Exposes defined repositories, relations and mappers
  #
  # @api public
  class Env
    include Equalizer.new(:repositories, :relations, :mappers, :commands)

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

    # @return [Registry] mapper registry
    #
    # @api public
    attr_reader :mappers

    # @api private
    def initialize(repositories, relations, readers, commands)
      @repositories = repositories
      @relations = relations
      @readers = readers
      @commands = commands
      initialize_mappers
      freeze
    end

    # Load relation by name
    #
    # @example
    #
    #   rom.relation(:users)
    #   rom.relation(:users) { |r| r.by_name('Jane') }
    #
    #   # with mapping
    #   rom.relation(:users).map_with(:presenter)
    #
    #   rom.relation(:users) { |r| r.page(1) }.map_with(:presenter, :json_serializer)
    #
    # @param [Symbol] name of the relation to load
    #
    # @yield [Relation]
    #
    # @return [Relation::Loaded]
    #
    # @api public
    def relation(name, &block)
      tuples =
        if block
          yield(relations[name])
        else
          relations[name]
        end

      Relation::Loaded.new(tuples.to_a, mappers[name])
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

    private

    # @api private
    def initialize_mappers
      elements = readers.each_with_object({}) { |(name, reader), h|
        h[name] = reader.mappers
      }
      @mappers = Registry.new(elements)
    end
  end
end
