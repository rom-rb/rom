# frozen_string_literal: true

require 'concurrent/map'

require 'rom/constants'
require 'rom/registry'

module ROM
  # Specialized registry class for commands
  #
  # @api public
  class CommandRegistry < Registry
    # Internal command registry
    #
    # @return [Registry]
    #
    # @api private
    param :elements

    # @!attribute [r] relation_name
    #   @return [Relation::Name] The name of a relation
    option :relation_name

    # @!attribute [r] mappers
    #   @return [MapperRegistry] Optional mapper registry
    option :mappers, optional: true

    # @!attribute [r] mapper
    #   @return [Object#call] Default mapper for processing command results
    option :mapper, optional: true

    # @!attribute [r] compiler
    #   @return [CommandCompiler] A command compiler instance
    option :compiler, optional: true

    # @api private
    def self.element_not_found_error
      CommandNotFoundError
    end

    # Return a command from the registry
    #
    # If mapper is set command will be turned into a composite command with
    # auto-mapping
    #
    # @overload [](name)
    #   @param [Symbol] name The command identifier from the registry
    #   @example
    #     create_user = rom.commands[:users][:create]
    #     create_user[name: 'Jane']
    #
    #     # with mapping, assuming :entity mapper is registered for :users relation
    #     create_user = rom.commands[:users].map_with(:entity)[:create]
    #     create_user[name: 'Jane'] # => result is sent through :entity mapper
    #
    # @overload [](*args)
    #   @param [Array] *args {CommandCompiler} arguments
    #   @see CommandCompiler#call
    #
    # @return [Command,Command::Composite]
    #
    # @api public
    def [](*args)
      if args.size.equal?(1)
        command = super
        mapper = options[:mapper]

        if mapper
          command.curry >> mapper
        else
          command
        end
      else
        cache.fetch_or_store(args.hash) { compiler.(*args) }
      end
    end

    # Specify a mapper that should be used for commands from this registry
    #
    # @example
    #   entity_commands = rom.commands[:users].map_with(:entity)
    #
    #
    # @param [Symbol] mapper_name The name of a registered mapper
    #
    # @return [CommandRegistry]
    #
    # @api public
    def map_with(mapper_name)
      with(mapper: mappers[mapper_name])
    end

    # @api private
    def set_compiler(compiler)
      options[:compiler] = @compiler = compiler
    end

    # @api private
    def set_mappers(mappers)
      options[:mappers] = @mappers = mappers
    end

    private

    # Allow checking if a certain command is available using dot-notation
    #
    # @api private
    def respond_to_missing?(name, include_private = false)
      key?(name) || super
    end

    # Allow retrieving commands using dot-notation
    #
    # @api private
    def method_missing(name, *)
      if key?(name)
        self[name]
      else
        super
      end
    end
  end
end
