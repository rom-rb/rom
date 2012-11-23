module DataMapper
  class Session
    class State
      # State for unpersisted objects
      class New < self

        # Insert via mapper and return loaded object state
        #
        # @param [Mapping] mapping
        #
        # @return [State::Loaded]
        #
        # @api private
        #
        def self.persist(mapping)
          mapper = mapping.mapper
          mapper.insert(mapping)

          Loaded.new(mapping)
        end

      end
    end
  end
end
