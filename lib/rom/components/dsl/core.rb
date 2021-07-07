# frozen_string_literal: true

require "dry/core/class_builder"

require "rom/constants"
require "rom/initializer"

module ROM
  module Components
    module DSL
      # @private
      class Core
        extend Dry::Core::ClassAttributes
        extend Initializer

        # @api private
        option :provider

        # @api private
        option :gateway, default: -> { :default }

        # @api private
        option :block, optional: true

        defines :configure

        # @api private
        def self.configure(*names, **mappings)
          if names.any? || mappings.any?
            return super((super() || EMPTY_HASH).merge(names.zip(names).to_h.merge(mappings)))
          end
          super
        end

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
            klass.config.component.update(component_options) unless component_options.empty?
            klass.class_exec(self, &block) if block
          end
        end

        private

        # @api private
        def component_options
          self.class.configure&.map { |source, target| [target, options[source]] }.to_h
        end

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
