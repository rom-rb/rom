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
    def initialize(repositories, relations, mappers, commands, readers = nil)
      @repositories = repositories
      @relations = relations
      @mappers = mappers
      @commands = commands
      @readers = readers
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
      relation =
        if block
          yield(relations[name])
        else
          relations[name]
        end

      if mappers.elements.key?(name)
        relation.to_lazy(mappers: mappers[name])
      else
        relation.to_lazy
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
    #
    # @deprecated
    #
    # @api public
    def read(name, &block)
      warn <<-MSG.gsub(/^\s+/, '')
        #{self.class}#read is deprecated.
        Please use `#{self.class}#relation(#{name.inspect})` instead.
        For mapping append `.map_with(:your_mapper_name)`
        [#{caller[0]}]
      MSG
      relation(name, &block)
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
