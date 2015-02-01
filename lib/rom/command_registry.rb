require 'rom/commands/evaluator'
require 'rom/commands/result'

module ROM
  # Command registry exposes "try" interface for executing commands
  #
  # @public
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
    def try(&f)
      Result::Success.new(Evaluator.new(self).evaluate(&f))
    rescue CommandError => e
      Result::Failure.new(e)
    end
  end
end
