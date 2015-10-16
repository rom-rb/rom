require 'rom/relation/loaded'
require 'rom/commands/graph'
require 'rom/commands/graph/dsl'
require 'rom/support/deprecations'

module ROM
  # Exposes defined gateways, relations and mappers
  #
  # @api public
  class Container
    extend Deprecations
    include Equalizer.new(:gateways, :relations, :mappers, :commands)

    # @return [Hash] configured gateways
    #
    # @api public
    attr_reader :gateways

    deprecate :repositories, :gateways

    # @return [RelationRegistry] relation registry
    #
    # @api private
    attr_reader :relations

    # @return [Registry] command registry
    #
    # @api private
    attr_reader :commands

    # @return [Registry] mapper registry
    #
    # @api public
    attr_reader :mappers

    # @api private
    def initialize(gateways, relations, mappers, commands)
      @gateways = gateways
      @relations = relations
      @mappers = mappers
      @commands = commands
      freeze
    end

    # Get lazy relation identified by its name
    #
    # @example
    #   rom.relation(:users)
    #   rom.relation(:users).by_name('Jane')
    #
    #   # block syntax allows accessing lower-level query DSLs (usage is discouraged though)
    #   rom.relation { |r| r.restrict(name: 'Jane') }
    #
    #   # with mapping
    #   rom.relation(:users).map_with(:presenter)
    #
    #   # using multiple mappers
    #   rom.relation(:users).page(1).map_with(:presenter, :json_serializer)
    #
    # @param [Symbol] name of the relation to load
    #
    # @yield [Relation]
    #
    # @return [Relation::Lazy]
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
        relation.with(mappers: mappers[name])
      else
        relation
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
    #   # allows auto-mapping using registered mappers
    #   rom.command(:users).as(:entity)
    #
    #   # allows building up a command graph for nested input
    #   command = rom.command([:users, [:create, [:tasks, [:create]]]])
    #
    #   command.call(users: [{ name: 'Jane', tasks: [{ title: 'One' }] }])
    #
    # @param [Array,Symbol] options Either graph options or registered command name
    #
    # @return [Command, Command::Graph]
    #
    # @api public
    def command(options = nil, &block)
      if block
        dsl = Commands::Graph::DSL.new
        command(dsl.call(&block))
      else
        case options
        when Symbol
          name = options
          if mappers.key?(name)
            commands[name].with(mappers: mappers[name])
          else
            commands[name]
          end
        when Array
          graph = Commands::Graph.build(commands, options)
          name = graph.name

          if mappers.key?(name)
            graph.with(mappers: mappers[graph.name])
          else
            graph
          end
        else
          raise ArgumentError, "#{self.class}#command accepts a symbol or an array"
        end
      end
    end
  end
end
