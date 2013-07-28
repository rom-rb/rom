module ROM
  class Session
    class State

      # @api private
      class Updated < self
        include Adamantium::Flat
        include Concord::Public.new(:object, :original_tuple, :relation)

        Commited = Class.new(self)

        # @api private
        def commit
          Commited.new(object, original_tuple, relation.update(object, original_tuple))
        end

      end # Updated

    end # State
  end # Session
end # ROM
