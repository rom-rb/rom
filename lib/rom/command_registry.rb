require 'rom/commands/result'

module ROM
  # Specialized registry class for commands
  #
  # @api public
  class CommandRegistry
    include Commands
    include Options

    # Internal command registry
    #
    # @return [Registry]
    #
    # @api private
    attr_reader :registry

    option :mappers, reader: true
    option :mapper, reader: true

    # @api private
    def initialize(elements, options = {})
      super
      @registry =
        if elements.is_a?(Registry)
          elements
        else
          Registry.new(elements, self.class.name)
        end
    end

    # Try to execute a command in a block
    #
    # @yield [command] Passes command to the block
    #
    # @example
    #
    #   rom.command(:users).try { create(name: 'Jane') }
    #   rom.command(:users).try { update(:by_id, 1).set(name: 'Jane Doe') }
    #   rom.command(:users).try { delete(:by_id, 1) }
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
    #   create_user = rom.command(:users)[:create]
    #   create_user[name: 'Jane']
    #
    #   # with mapping, assuming :entity mapper is registered for :users relation
    #   create_user = rom.command(:users).as(:entity)[:create]
    #   create_user[name: 'Jane'] # => result is send through :entity mapper
    #
    # @param [Symbol] name The name of a registered command
    #
    # @return [Command,Command::Composite]
    #
    # @api public
    def [](name)
      command = registry[name]
      mapper = options[:mapper]

      if mapper
        command.curry >> mapper
      else
        command
      end
    end

    # Specify a mapper that should be used for commands from this registry
    #
    # @example
    #   entity_commands = rom.command(:users).as(:entity)
    #
    #
    # @param [Symbol] mapper_name The name of a registered mapper
    #
    # @return [CommandRegistry]
    #
    # @api public
    def as(mapper_name)
      with(mapper: mappers[mapper_name])
    end

    # Return new instance of this registry with updated options
    #
    # @return [CommandRegistry]
    #
    # @api private
    def with(new_options)
      self.class.new(registry, options.merge(new_options))
    end

    private

    # Allow retrieving commands using dot-notation
    #
    # @api private
    def method_missing(name, *)
      if registry.key?(name)
        self[name]
      else
        super
      end
    end
  end
end
