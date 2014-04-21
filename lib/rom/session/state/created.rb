# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Created < self
        include Adamantium::Flat

        # @api private
        def commit
          Persisted.new(object, relation.insert!(object))
        end

      end # Created

    end # State
  end # Session
end # ROM
