# encoding: utf-8

module ROM
  class Mapper
    class Mapping

      class Registry

        include Enumerable

        attr_reader :entries
        private     :entries

        def initialize(entries = EMPTY_HASH)
          @entries = entries.dup
        end

        def register(model, &block)
          entries[model] = Mapping.new(model, &block)
        end

        def [](model)
          entries.fetch(model)
        end

        def each(&block)
          return to_enum unless block
          entries.each(&block)
          self
        end
      end # class Registry
    end # class Mapping
  end # class Mapper
end # module ROM
