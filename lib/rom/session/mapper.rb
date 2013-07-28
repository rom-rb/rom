module ROM
  class Session

    # @api private
    class Mapper < ROM::Mapper
      include Proxy, Concord::Public.new(:mapper, :tracker, :identity_map)

      # @api private
      def dirty?(object)
        identity_map.fetch_tuple(identity(object)) != dump(object)
      end

      # @api private
      def load(tuple)
        identity = mapper.identity_from_tuple(tuple)
        identity_map.fetch_object(identity) { load_and_track(identity, tuple) }
      end

      # @api private
      def store_in_identity_map(object)
        identity_map.store(identity(object), object, dump(object))
      end

      private

      # @api private
      def load_and_track(identity, tuple)
        object = mapper.load(tuple)
        tracker.store_persisted(object, self)
        identity_map.store(identity, object, tuple)[identity]
      end

    end # Mapper

  end # Session
end # ROM
