module ROM
  module Plugins
    module Relation
      module Instrumentation
        # This hooks sets up a relation class with injectible notifications object
        #
        # @api private
        def self.included(klass)
          super

          klass.class_eval do
            defines :notifications

            option :notifications, reader: true, default: -> relation {
              relation.class.notifications.()
            }
          end
        end

        # Experimental plugin for configuring relations with an external
        # instrumentation system like dry-monitor or ActiveSupport::Notifications
        #
        # @api public
        def to_a
          instrument { super }
        end

        # @api public
        def instrument(&block)
          notifications.instrument(self.class.adapter, { name: name.relation }.merge(notification_payload), &block)
        end

        private

        # @api private
        def notification_payload
          EMPTY_HASH
        end
      end
    end
  end
end
