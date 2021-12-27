# frozen_string_literal: true

require "dry/core/memoizable"
require "dry/core/class_builder"

require "rom/constants"
require "rom/initializer"

module ROM
  module Components
    module DSL
      # @private
      class Core
        extend Initializer
        extend Dry::Core::ClassAttributes

        defines(:key, :type, :nested)

        include Dry::Core::Memoizable

        nested false

        # @api private
        option :provider

        # @api private
        option :config, optional: true, default: -> { EMPTY_HASH }

        # @api private
        option :plugins, default: -> {
          if config.key?(:plugins)
            config.plugins.select { |plugin| plugin.type == type }
          else
            EMPTY_ARRAY
          end
        }

        # @api private
        option :block, optional: true

        # @api private
        def self.inherited(klass)
          super
          klass.type(Inflector.component_id(klass).to_sym)
        end

        # @api private
        def build_class(name: class_name, parent: class_parent, &block)
          Dry::Core::ClassBuilder.new(name: name, parent: parent).call do |klass|
            klass.config.component.update(config)
            klass.class_exec(self, &block) if block
          end
        end

        # @api private
        def key
          self.class.key
        end

        # @api private
        def type
          self.class.type
        end

        # @api private
        def call(**options)
          components.add(key, config: configure, block: block, **options)
        end

        # @api private
        def configure
          config.freeze
        end

        # Enable a plugin in a DSL
        #
        # @param [Symbol] name Plugin name
        # @param [Hash] options Plugin options
        #
        # @api public
        def use(name, **options)
          plugin = ::ROM.plugins[type].fetch(name, adapter).configure do |config|
            config.update(options)
          end
          plugin.enable(self).apply
          self
        end

        # @api private
        def plugin(name, **options)
          plugin = plugins.detect { |plugin| plugin.name == name }
          plugin.config.update(options) unless options.empty?
          plugin
        end

        private

        # @api private
        def components
          provider.components
        end

        # @api private
        def inflector
          provider.config.component.inflector
        end

        # @api private
        def class_name_inferrer
          provider.config.class_name_inferrer
        end

        # @api private
        memoize def adapter
          config.adapter || gateway_adapter
        end

        # @api private
        def gateway_adapter
          if provider.config.key?(:gateways)
            provider.config.gateways[config.gateway]&.fetch(:adapter)
          end
        end
      end
    end
  end
end
