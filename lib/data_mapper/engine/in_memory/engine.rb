module DataMapper
  class Engine
    module InMemory
      class Engine < DataMapper::Engine

        def base_relation(name, header = nil)
          Relation.new(name)
        end
      end # class Engine
    end # module InMemory
  end # class Engine
end # module DataMapper
