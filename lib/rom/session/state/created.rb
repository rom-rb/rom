module ROM
  class Session
    class State

      # @api private
      class Created < self
        include Concord::Public.new(:object, :relation), Adamantium::Flat

        Commited = Class.new(self)

        # @api private
        def commit
          Commited.new(object, relation.insert(object))
        end

      end # Created

    end # State
  end # Session
end # ROM
