# frozen_string_literal: true

require "dry/core/class_attributes"
require "rom/mapper/attribute_dsl"

module ROM
  class Mapper
    # Mapper class-level DSL including Attribute DSL and Model DSL
    module DSL
      # Extend mapper class with macros and DSL methods
      #
      # @api private
      def self.included(klass)
        klass.extend(Dry::Core::ClassAttributes)
        klass.extend(ClassMethods)
      end

      # Class methods for all mappers
      #
      # @private
      module ClassMethods
        # Set base ivars for the mapper class
        #
        # @api private
        def inherited(klass)
          super

          klass.instance_variable_set("@attributes", nil)
          klass.instance_variable_set("@header", nil)
          klass.instance_variable_set("@attribute_dsl", nil)
        end

        # include a registered plugin in this mapper
        #
        # @param [Symbol] plugin
        # @param [Hash] options
        # @option options [Symbol] :adapter (:default) first adapter to check for plugin
        #
        # @api public
        def use(plugin, options = {})
          adapter = options.fetch(:adapter, :default)

          ROM.plugins[:mapper].fetch(plugin, adapter).apply_to(self)
        end

        # Return base_relation used for creating mapper registry
        #
        # This is used to "gather" mappers under same root name
        #
        # @api private
        def base_relation
          superclass.relation || relation
        end

        # Return header of the mapper
        #
        # This is memoized so mutating mapper class won't have an effect wrt
        # header after it was initialized for the first time.
        #
        # TODO: freezing mapper class here is probably a good idea
        #
        # @api private
        def header
          @header ||= attribute_dsl.header
        end

        # @api private
        def respond_to_missing?(name, _include_private = false)
          attribute_dsl.respond_to?(name) || super
        end

        private

        # Return default Attribute DSL options based on settings of the mapper
        # class
        #
        # @api private
        def options
          {copy_keys: copy_keys,
           prefix: prefix,
           prefix_separator: prefix_separator,
           symbolize_keys: symbolize_keys,
           reject_keys: reject_keys}
        end

        # Return default attributes that might have been inherited from the
        # superclass
        #
        # @api private
        def attributes
          @attributes ||=
            if superclass.respond_to?(:attributes, true) && config.inherit_header
              superclass.__send__(:attributes).dup
            else
              []
            end
        end

        # Create the attribute DSL instance used by the mapper class
        #
        # @api private
        def attribute_dsl
          @attribute_dsl ||= AttributeDSL.new(attributes, config.to_h)
        end

        # Delegate Attribute DSL method to the dsl instance
        #
        # @api private
        def method_missing(name, *args, &block)
          if attribute_dsl.respond_to?(name)
            attribute_dsl.public_send(name, *args, &block)
          else
            super
          end
        end
        ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)
      end
    end
  end
end
