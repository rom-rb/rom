# frozen_string_literal: true

require "rom/schema/associations_dsl"

require_relative "core"

module ROM
  module Components
    module DSL
      # Setup DSL-specific relation extensions
      #
      # @private
      class Association < Core
        key :associations

        # @api private
        def call
          configure

          backend.instance_eval(&block)

          backend.call.each do |definition|
            assoc_config = config.merge(id: definition.id, namespace: namespace, **definition.to_h)

            components.add(key, definition: definition, config: assoc_config)
          end
        end

        # @api private
        def backend
          @backend ||= ROM::Schema::AssociationsDSL.new(source, inflector)
        end

        # @api private
        def namespace
          [provider.config.association.namespace, source]
        end

        # @api private
        def source
          config.source || config.id
        end
      end
    end
  end
end
