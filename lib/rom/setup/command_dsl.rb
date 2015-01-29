module ROM
  class Setup
    class CommandDSL
      attr_reader :relation

      def initialize(relation, &block)
        @relation = relation
        instance_exec(&block)
      end

      def define(name, options = {}, &block)
        Command.build_class(name, relation, options, &block)
      end
    end
  end
end
