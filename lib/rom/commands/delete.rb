# frozen_string_literal: true

require "rom/command"

module ROM
  module Commands
    # Delete command
    #
    # This command removes tuples from its target relation
    #
    # @abstract
    class Delete < Command
      config.restrictable = true
    end
  end
end
