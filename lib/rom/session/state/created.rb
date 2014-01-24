# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Created < self
        include Concord::Public.new(:object, :mapper, :relation), Adamantium::Flat

        # @api private
        def commit
          relation.insert(object)
          mapper.store_in_identity_map(object)
          Persisted.new(object, mapper)
        end

      end # Created

    end # State
  end # Session
end # ROM
