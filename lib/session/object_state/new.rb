module Session
  # An objects persistance state
  class ObjectState
    # An ObjectState that represents a new unpersisted domain object.
    class New < ObjectState
      # Insert via mapper and return loaded object state
      #
      # @return [ObjectState::Loaded]
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
