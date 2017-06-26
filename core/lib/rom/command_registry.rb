require 'concurrent/map'

require 'rom/constants'
require 'rom/registry'
require 'rom/commands/result'

module ROM
  # Specialized registry class for commands
  #
  # @api public
  class CommandRegistry < Registry
    include Commands

    # Internal command registry
    #
    # @return [Registry]
    #
    # @api private
    param :elements

    # Name of the relation from which commands are under
    #
    # @return [String]
    #
    # @api private
    option :relation_name

    option :mappers, optional: true

    option :mapper, optional: true

    option :compiler, optional: true

    def self.element_not_found_error
      CommandNotFoundError
    end

    # Try to execute a command in a block
    #
    # @yield [command] Passes command to the block
    #
    # @example
    #
    #   rom.commands[:users].try { create(name: 'Jane') }
    #   rom.commands[:users].try { update(:by_id, 1).call(name: 'Jane Doe') }
    #   rom.commands[:users].try { delete(:by_id, 1) }
    #
    # @return [Commands::Result]
    #
    # @api public
    def try(&block)
      response = block.call

      if response.is_a?(Command) || response.is_a?(Composite)
        try { response.call }
      else
        Result::Success.new(response)
      end
    rescue CommandError => e
      Result::Failure.new(e)
    end

    # Return a command from the registry
    #
    # If mapper is set command will be turned into a composite command with
    # auto-mapping
    #
    # @example
    #   create_user = rom.commands[:users][:create]
    #   create_user[name: 'Jane']
    #
    #   # with mapping, assuming :entity mapper is registered for :users relation
    #   create_user = rom.commands[:users].map_with(:entity)[:create]
    #   create_user[name: 'Jane'] # => result is send through :entity mapper
    #
    # @param [Symbol] name The name of a registered command
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
