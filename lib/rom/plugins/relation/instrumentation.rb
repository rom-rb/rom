module ROM
  module Plugins
    module Relation
      # Experimental plugin for configuring relations with an external
      # instrumentation system like dry-monitor or ActiveSupport::Notifications
      #
      # @api public
      module Instrumentation
        # This hooks sets up a relation class with injectible notifications object
        #
        # @api private
        def self.included(klass)
          super
          klass.option :notifications, reader: true
          klass.extend(ClassInterface)
          klass.instrument(:to_a)
        end

        module ClassInterface
          def instrument(*methods)
            methods.each do |meth|
              define_method(meth) do
                instrument { super() }
              end
            end
          end
        end

        # @api public
        def instrument(&block)
          notifications.instrument(self.class.adapter, { name: name.relation }.merge(notification_payload(self)), &block)
        end

        private

        # @api private
        def notification_payload(relation)
          EMPTY_HASH
        end
      end
    end
  end
end
