module ROM
  class Session

    class Tracker

      def initialize
        @identity_map = Hash.new { |hash, key| hash[key] = {} }
      end

      def fetch(relation_name)
        @identity_map[relation_name]
      end

    end # Tracker

  end # Session
end # ROM
