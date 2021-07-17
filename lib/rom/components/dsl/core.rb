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
        option :block, optional: true

        # Specifies which DSL options map to component's settings
        #
        # @api private
        def self.settings(*keys, **mappings)
          if defined?(@settings) && (keys.empty? && mappings.empty?)
            @settings
          else
            @settings = [keys.zip(keys).to_h, **mappings].reduce(:merge)
          end
        end

        # @api private
        def self.inherited(klass)
          super
          klass.instance_variable_set(:@settings, EMPTY_HASH)
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
        def add(**options)
          components.add(key, block: block, config: config, **options)
        end
        alias_method :call, :add

        private

        # @api private
        def components
          provider.components
        end

        # @api private
        def inflector
          provider.inflector
        end

        # @api private
        def class_name_inferrer
          provider.class_name_inferrer
        end

        # @api private
        memoize def adapter
          config.adapter || provider.config.gateways[config.gateway]&.fetch(:adapter)
        end
      end
    end
  end
end
