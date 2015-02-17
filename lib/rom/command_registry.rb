require 'rom/commands/result'

module ROM
  # Command registry exposes "try" interface for executing commands
  #
  # @api public
  class CommandRegistry < Registry
    include Commands

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
    #   rom.command(:users).try { |command| command.create(name: 'Jane') }
    #   rom.command(:users).try { |command| command.delete(:by_id, 1) }
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
  end
end
