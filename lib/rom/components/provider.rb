# frozen_string_literal: true

require "rom/support/configurable"

require "rom/core"
require "rom/settings"
require "rom/registries/root"

require_relative "dsl"
require_relative "registry"

module ROM
  # Define a module for component definitions and runtime setup
  #
  # @return [Components::Provider]
  #
  # @api public
  def self.Provider(*features, **options)
    Components::Provider.new(features, **options)
  end

  # @api private
  module Components
    # @api private
    class Provider < Module
      attr_reader :provider

      attr_reader :type

      attr_reader :features

      # @api private
      module InstanceMethods
        # @api public
        def components
          @components ||= Registry.new(provider: self)
        end

        # @api private
        def registry(**options)
          Registries::Root.new(
            config: config,
            components: components,
            notifications: Notifications.event_bus(:configuration),
            **options
          )
        end
      end

      # @api private
      module ClassMethods
        include InstanceMethods

        # @api private
        def inherited(klass)
          super
          klass.components.update(components, abstract: true)
        end
      end

      # @api private
      def initialize(features, type: nil)
        super()
        @provider = nil
        @type = type
        @features = features
      end

      # @api private
      def define_configure_method(type, features, &block)
        yield Module.new {
                define_method(:configure) do |*args, &block|
                  # Inherit global defaults
                  config.component.inherit!(**ROM.config[type], type: type)

                  # Inherit global defaults for individual features
                  features.each do |name|
                    config[name].inherit!(**ROM.config[name]) if ROM.config.key?(name)
                  end

                  super(*args, &block)
                end
              }
      end

      # @api private
      def included(provider)
        super
        @provider = provider
        provider.include(mod)
        provider.include(Configurable)
        import_settings
        provider.include(InstanceMethods)
        define_configure_method(type, features) { |mod|
          provider.prepend(mod)
        }
        freeze
      end

      # @api private
      def extended(provider)
        super
        @provider = provider
        provider.extend(mod)
        provider.extend(Configurable)
        import_settings
        provider.extend(ClassMethods)
        define_configure_method(type, features) { |mod|
          provider.singleton_class.prepend(mod)
        }
        freeze
      end

      # @api private
      def mod
        @mod ||=
          Module.new.tap do |mod|
            define_dsl_method(mod, :__dsl__)

              features.each do |type|
                if ROM.components.key?(type)
                  handler = ROM.components[type]

                  [handler.key, handler.namespace]
                    .select { |name|
                      DSL.instance_methods.include?(name)
                    }
                    .each { |name|
                      define_dsl_method(mod, name)
                    }
                else
                  define_dsl_method(mod, type)
                end
              end
          end

      end

      # @api private
      def define_dsl_method(mod, name)
        mod.define_method(name) { |*args, **opts, &block|
          DSL.instance_method(name).bind(self).(*args, **opts, &block)
        }
      end

      # @api private
      def import_settings
        # Import default settings for the provider
        provider.setting(:component, import: ROM.settings[type])

        # Import default settings for each feature that the provider supports
        features.each do |name|
          if ROM.settings.key?(name)
            # Define the settings
            provider.setting(name, import: ROM.settings[name])
          end
        end
      end
    end
  end
end
