module ROM

  class Reader
    include Charlatan.new(:relation)

    class DSL

      class ReaderBuilder
        attr_reader :relation

        def initialize(relation)
          @relation = relation
        end

        def call(&block)
          mod = Module.new
          mod.module_exec(&block)

          Class.new(Reader).send(:include, mod).new(relation)
        end
      end

      attr_reader :relations, :readers

      def initialize(relations)
        @relations = relations
        @readers = {}
      end

      def call
        readers
      end

      def method_missing(name, *args, &block)
        relation = relations[name]
        builder = ReaderBuilder.new(relation)
        reader = builder.call(&block)

        readers[name] = reader
      end
    end

    def self.define(relations, &block)
      dsl = DSL.new(relations)
      dsl.instance_exec(&block)
      dsl.call
    end

  end
end
