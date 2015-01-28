module ROM
  class Setup
    class CommandDSL
      attr_reader :relation

      def initialize(relation, &block)
        @relation = relation
        instance_exec(&block)
      end

      def define(name, options = {}, &block)
        type = options.fetch(:type) { name }
        class_name = "ROM::Command[#{relation}][#{type}]"

        ClassBuilder.new(name: class_name, parent: Command).call do |klass|
          klass.type(type)
          klass.register_as(name)
          klass.relation(relation)
          klass.class_eval(&block) if block
          options.each { |k, v| klass.send(k, v) }
        end
      end
    end
  end
end
