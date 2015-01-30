require 'rom/setup_dsl/command'

module ROM
  class Setup
    class CommandDSL
      attr_reader :relation, :adapter

      def initialize(relation, adapter = nil, &block)
        @relation = relation
        @adapter = adapter
        instance_exec(&block)
      end

      def define(name, options = {}, &block)
        Command.build_class(
          name, relation, { adapter: adapter }.merge(options), &block
        )
      end
    end
  end
end
