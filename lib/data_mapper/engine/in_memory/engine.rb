module DataMapper
  class Engine
    module InMemory
      class Engine < DataMapper::Engine
        register_as :in_memory

        def base_relation(name, header = nil)
          Relation.new(name)
        end
      end # class Engine
    end # module InMemory
  end # class Engine
end # module DataMapper
