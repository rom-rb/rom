require 'dry/core/class_attributes'

module ROM
  module Plugins
    module Relation
      # Experimental plugin for configuring relations with an external
      # instrumentation system like dry-monitor or ActiveSupport::Notifications
      #
      # @api public
      module Instrumentation
        extend Dry::Core::ClassAttributes

        # This hooks sets up a relation class with injectible notifications object
        #
        # @api private
        def self.included(klass)
          super
          klass.option :notifications
          klass.extend(ClassInterface)
          klass.prepend(mixin)
          klass.instrument(:to_a)
        end

        defines :mixin
        mixin Module.new

        module ClassInterface
          def instrument(*methods)
            (methods - Instrumentation.mixin.instance_methods).each do |meth|
              Instrumentation.mixin.send(:define_method, meth) do
                instrument { super() }
              end
            end
          end
        end

        # @api public
        def instrument(&block)
          notifications.instrument(self.class.adapter, name: name.relation, **notification_payload(self), &block)
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
