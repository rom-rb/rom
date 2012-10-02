module Session
  class State
    # An State that represents a new unpersisted domain object.
    class New < self
      # Insert via mapper and return loaded object state
      #
      # @return [State::Loaded]
      #
      # @api private
      #
      def persist
        @mapper.insert_dump(dump)

        Loaded.new(@mapper, @object)
      end
    end
  end
end
