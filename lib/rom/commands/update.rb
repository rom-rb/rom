# frozen_string_literal: true

require "rom/command"

module ROM
  module Commands
    # Update command
    #
    # This command updates all tuples in its relation with new attributes
    #
    # @abstract
    class Update < Command
      restrictable true
    end
  end
end
