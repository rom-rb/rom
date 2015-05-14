require 'rom/relation/loaded'
require 'rom/support/deprecations'

module ROM
  # Exposes defined repositories, relations and mappers
  #
  # @api public
  class Env
    extend Deprecations
    include Equalizer.new(:repositories, :relations, :mappers, :commands)

    # @return [Hash] configured repositories
    #
    # @api public
    attr_reader :repositories

    # @return [RelationRegistry] relation registry
    #
    # @api public
    attr_reader :relations

    # @return [Registry] command registry
    #
    # @api public
    attr_reader :commands

    # @return [Registry] mapper registry
    #
    # @api public
    attr_reader :mappers

    # @api private
    def initialize(repositories, relations, mappers, commands)
      @repositories = repositories
      @relations = relations
      @mappers = mappers
      @commands = commands
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

      if mappers.key?(name)
        relation.to_lazy(mappers: mappers[name])
      else
        relation.to_lazy
      end
    end
    deprecate :read, :relation, "For mapping append `.map_with(:your_mapper_name)`"

    # Returns commands registry for the given relation
    #
    # @example
    #
    #   # plain command returning tuples
    #   rom.command(:users).create
    #
    #   # allow auto-mapping using registered mappers
    #   rom.command(:users).as(:entity)
    #
    # @api public
    def command(name)
      if mappers.key?(name)
        commands[name].with(mappers: mappers[name])
      else
        commands[name]
      end
    end
  end
end
