module ROM
  module Commands

    class AbstractCommand
      attr_reader :relation, :options

      def initialize(relation, options)
        @relation = relation
        @options = options
      end

    end

  end
end

require 'rom/commands/create'
require 'rom/commands/update'
require 'rom/commands/delete'
