module Session
  class State
    # State for unpersisted objects
    class New < self

      # Insert via mapper and return loaded object state
      #
      # @return [State::Loaded]
      #
      # @api private
      #
      def persist
        mapper.insert(self)

        Loaded.new(self)
      end

    end
  end
end
