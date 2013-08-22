# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Updated < self
        include Adamantium::Flat
        include Concord::Public.new(:object, :mapper, :relation)

        # @api private
        def commit
          relation.update(object, original_tuple)
          Persisted.new(object, mapper)
        end

        private

        # @api private
        def original_tuple
          mapper.identity_map.fetch_tuple(mapper.identity(object))
        end

      end # Updated

    end # State
  end # Session
end # ROM
