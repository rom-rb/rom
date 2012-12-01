module DataMapper
  class Engine
    module InMemory

      class Relation
        include Enumerable

        attr_reader :name

        def initialize(name)
          @name = name
          reset!
        end

        def each(&block)
          return to_enum unless block_given?
          @data.each_value(&block)
          self
        end

        def insert(tuple)
          @data[@seq += 1] = tuple
          @seq
        end

        def update(*args)
          raise NotImplementedError
        end

        def delete(key)
          @data.delete(key.values[0])
        end

        def reset!
          @data = {}
          @seq  = 0
        end
      end # class Relation
    end # module InMemory
  end # class Engine
end # module DataMapper
