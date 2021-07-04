# frozen_string_literal: true

require "dry/core/class_builder"

require "rom/initializer"

module ROM
  module Components
    module DSL
      # @private
      class Core
        extend Initializer

        # @api private
        option :configuration

        # @api private
        option :gateway, default: -> { :default }

        # @api private
        option :block

        # @api private
        def initialize(**options, &block)
          if block
            super(**options, block: block)
          else
            super
          end
        end

        # @api private
        def build_class(name: class_name, parent: class_parent, **options, &block)
          Dry::Core::ClassBuilder.new(name: name, parent: parent).call do |klass|
            klass.class_exec(self, &block) if block
          end
        end

        private

        # @api private
        def components
          configuration.components
        end

        # @api private
        def inflector
          configuration.inflector
        end

        # @api private
        def class_name_inferrer
          configuration.class_name_inferrer
        end

        # @api private
        def config
          configuration.config
        end
      end
    end
  end
end
