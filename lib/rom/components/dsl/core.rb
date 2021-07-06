# frozen_string_literal: true

require "dry/core/class_builder"

require "rom/constants"
require "rom/initializer"

module ROM
  module Components
    module DSL
      # @private
      class Core
        extend Initializer

        # @api private
        option :provider

        # @api private
        option :gateway, default: -> { :default }

        # @api private
        option :block, optional: true

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
        def config
          provider.config
        end
      end
    end
  end
end
