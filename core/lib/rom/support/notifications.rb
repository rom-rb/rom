require 'dry/equalizer'

require 'rom/constants'

module ROM
  module Notifications
    LISTENERS_HASH = Hash.new { |h, k| h[k] = [] }

    module Publisher
      # @api public
      def subscribe(event_id, query = EMPTY_HASH, &block)
        listeners[event_id] << [block, query]
        self
      end

      # @api public
      def trigger(event_id, payload = EMPTY_HASH)
        event = events[event_id]

        listeners[event.id].each do |(listener, query)|
          event.payload(payload).trigger(listener, query)
        end
      end
    end

    class Event
      include Dry::Equalizer(:id, :payload)

      attr_reader :id

      def initialize(id, payload = EMPTY_HASH)
        @id = id
        @payload = payload
      end

      def [](name)
        @payload.fetch(name)
      end

      def payload(data = nil)
        if data
          self.class.new(id, @payload.merge(data))
        else
          @payload
        end
      end

      def trigger(listener, query = EMPTY_HASH)
        listener.(self) if trigger?(query)
      end

      def trigger?(query)
        query.empty? || query.all? { |key, value| @payload[key] == value }
      end
    end

    extend Publisher

    # @api public
    def register_event(id, info = EMPTY_HASH)
      Notifications.events[id] = Event.new(id, info)
    end

    # @api private
    def self.events
      @__events__ ||= {}
    end

    # @api private
    def self.listeners
      @__listeners__ ||= LISTENERS_HASH.dup
    end

    # @api public
    def self.event_bus(id)
      EventBus.new(id, events: events.dup, listeners: listeners.dup)
    end

    # @api public
    module Listener
      # @api public
      def subscribe(event_id, query = EMPTY_HASH, &block)
        Notifications.listeners[event_id] << [block, query]
      end
    end

    # @api public
    class EventBus
      include Publisher

      attr_reader :id
      attr_reader :events
      attr_reader :listeners

      # @api public
      def initialize(id, events: EMPTY_HASH, listeners: LISTENERS_HASH.dup)
        @id = id
        @listeners = listeners
        @events = events
      end
    end
  end
end
