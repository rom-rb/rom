# encoding: utf-8

module ROM
  class Session

    # @api private
    class Mapper
      include Charlatan.new(:mapper)

      attr_reader :tracker, :identity_map

      def initialize(mapper, tracker, identity_map)
        super
        @tracker = tracker
        @identity_map = identity_map
      end

      # @api private
      def self.build(mapper, tracker)
        new(mapper, tracker, IdentityMap.build)
      end

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
