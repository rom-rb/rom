require 'rom/command'
require 'rom/commands/create'
require 'rom/commands/update'

# TODO: these extensions should be moved to rom core at some point
module ROM
  class Command
    defines :restrictable

    # @api private
    def self.create_class(name, type)
      ClassBuilder
        .new(name: "#{Inflector.classify(type)}[:#{name}]", parent: type)
        .call
    end
  end

  module Commands
    class Lazy
      def unwrap
        command
      end
    end

    class Update < Command
      restrictable true
    end

    class Delete < Command
      restrictable true
    end
  end
end
