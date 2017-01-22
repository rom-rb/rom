require 'dry/core/inflector'

module ROM
  class Repository
    # TODO: look into making command graphs work without the root key in the input
    #       so that we can get rid of this wrapper
    #
    # @api private
    class CommandProxy
      attr_reader :command, :root

      def initialize(command)
        @command = command
        @root = Dry::Core::Inflector.singularize(command.name.relation).to_sym
      end

      def call(input)
        command.call(root => input)
      end

      def >>(other)
        self.class.new(command >> other)
      end
    end
  end
end
