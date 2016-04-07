module ROM
  class Repository
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
