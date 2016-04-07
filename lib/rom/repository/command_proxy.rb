module ROM
  class Repository
    # TODO: look into making command graphs work without the root key in the input
    #       so that we can get rid of this wrapper
    class CommandProxy
      attr_reader :command, :root

      def initialize(command)
        @command = command
        @root = Inflector.singularize(command.relation.name).to_sym
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
