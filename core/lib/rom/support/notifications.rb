# frozen_string_literal: true

require 'rom/constants'

module ROM
  # Notification subsystem
  #
  # This is an abstract event bus that implements a simple pub/sub protocol.
  # The Notifications module is used in the setup process to decouple
  # different modules from each other.
  #
  # @example
  #   class Setup
  #     extend ROM::Notifications
  #
  #     register_event('setup.before_setup')
  #     register_event('setup.after_setup')
  #
  #     def initialize
  #       @bus = Notifications.event_bus(:setup)
  #     end
  #
  #     def setup
  #       @bus.trigger('setup.before_setup', at: Time.now)
  #       # ...
  #       @bus.trigger('setup.after_setup', at: Time.now)
  #     end
  #   end
  #
  #   class Plugin
  #     extend ROM::Notifications::Listener
  #
  #     subscribe('setup.after_setup') do |event|
  #       puts "Loaded at #{event.at.iso8601}"
  #     end
  #   end
  #
  module Notifications
    LISTENERS_HASH = Hash.new { |h, k| h[k] = [] }

    # Extension used for classes that can trigger events
    #
    # @api public
    module Publisher
      # Subscribe to events.
      # If the query parameter is provided, filters events by payload.
      #
      # @param [String] event_id The event key
      # @param [Hash] query An optional event filter
      # @yield [block] The callback
      # @return [Object] self
      #
      # @api public
      def subscribe(event_id, query = EMPTY_HASH, &block)
        listeners[event_id] << [block, query]
        self
      end

      # Trigger an event
      #
      # @param [String] event_id The event key
      # @param [Hash] payload An optional payload
      #
      # @api public
      def trigger(event_id, payload = EMPTY_HASH)
        event = events[event_id]

        listeners[event.id].each do |(listener, query)|
          event.payload(payload).trigger(listener, query)
        end
      end
    end

    # Event object
    #
    # @api public
    class Event
      include Dry::Equalizer(:id, :payload)

      # @!attribute [r] id
      #   @return [Symbol] The event identifier
      attr_reader :id

      # Initialize a new event
      #
      # @param [Symbol] id The event identifier
      # @param [Hash] payload Optional payload
      #
      # @return [Event]
      #
      # @api private
      def initialize(id, payload = EMPTY_HASH)
        @id = id
        @payload = payload
      end

      # Get data from the payload
      #
      # @param [String,Symbol] name
      #
      # @api public
      def [](name)
        @payload.fetch(name)
      end

      # Coerce an event to a hash
      #
      # @return [Hash]
      #
      # @api public
      def to_h
        @payload
      end
      alias_method :to_hash, :to_h

      # Get or set a payload
      #
      # @overload
      #   @return [Hash] payload
      #
      # @overload payload(data)
      #   @param [Hash] data A new payload
      #   @return [Event] A copy of the event with the provided payload
      #
      # @api public
      def payload(data = nil)
        if data
          self.class.new(id, @payload.merge(data))
        else
          @payload
        end
      end

      # Trigger the event
      #
      # @param [#call] listener
      # @param [Hash] query
      #
      # @api private
      def trigger(listener, query = EMPTY_HASH)
        listener.(self) if trigger?(query)
      end

      # @api private
      def trigger?(query)
        query.empty? || query.all? { |key, value| @payload[key] == value }
      end
    end

    extend Publisher

    # Register an event
    #
    # @param [String] id A unique event key
    # @param [Hash] info
    #
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

    # Build an event bus
    #
    # @param [Symbol] id Bus key
    # @return [Notifications::EventBus] A new bus
    #
    # @api public
    def self.event_bus(id)
      EventBus.new(id, events: events.dup, listeners: listeners.dup)
    end

    # Extension for objects that can listen to events
    #
    # @api public
    module Listener
      # Subscribe to events
      #
      # @param [String] event_id The event key
      # @param [Hash] query An optional event filter
      # @return [Object] self
      #
      # @api public
      def subscribe(event_id, query = EMPTY_HASH, &block)
        Notifications.listeners[event_id] << [block, query]
      end
    end

    # Event bus
    #
    # An event bus stores listeners (callbacks) and events
    #
    # @api public
    class EventBus
      include Publisher

      # @!attribute [r] id
      #   @return [Symbol] The bus identifier
      attr_reader :id

      # @!attribute [r] events
      #   @return [Hash] A hash with events registered within a bus
      attr_reader :events

      # @!attribute [r] listeners
      #   @return [Hash] A hash with event listeners registered within a bus
      attr_reader :listeners

      # Initialize a new event bus
      #
      # @param [Symbol] id The bus identifier
      # @param [Hash] events A hash with events
      # @param [Hash] listeners A hash with listeners
      #
      # @api public
      def initialize(id, events: EMPTY_HASH, listeners: LISTENERS_HASH.dup)
        @id = id
        @listeners = listeners
        @events = events
      end
    end
  end
end
