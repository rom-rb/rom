module ROM
  class Session

    # @api private
    class Mapper < ROM::Mapper
      include Proxy, Concord::Public.new(:mapper, :identity_map)

      # @api private
      def dirty?(object)
        identity_map.fetch_tuple(identity(object)) != dump(object)
      end

      # @api private
      def load(tuple)
        identity = mapper.loader.identity(tuple)

        identity_map.fetch(identity) {
          identity_map.store(identity, mapper.load(tuple), tuple)[identity]
        }
      end

    end # Mapper

  end # Session
end # ROM
