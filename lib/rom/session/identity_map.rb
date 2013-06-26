module ROM
  class Session

    # @api private
    class IdentityMap
      include Concord.new(:objects)

      LoadedObject = Class.new { include Concord::Public.new(:object, :tuple) }

      # @api private
      def self.new(objects = {})
        super(objects)
      end

      # @api private
      def [](identity)
        objects[identity]
      end

      # @api private
      def fetch(identity, &block)
        objects.fetch(identity, &block).object
      end

      # @api private
      def fetch_tuple(identity)
        self[identity].tuple
      end

      # @api private
      def store(identity, object, tuple)
        objects[identity] = LoadedObject.new(object, tuple)
        self
      end

    end # IdentityMap

  end # Session
end # ROM
