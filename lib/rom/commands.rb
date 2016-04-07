require 'rom/command'
require 'rom/commands/create'
require 'rom/commands/update'

# TODO: these extensions should be moved to rom core at some point
module ROM
  class Command
    defines :restrictable
  end

  module Commands
    class Update < Command
      restrictable true
    end

    class Delete < Command
      restrictable true
    end
  end
end
