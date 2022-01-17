# frozen_string_literal: true

require "rom/schema/associations_dsl"
require "rom/relation/name"

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
            components.add(key, definition: definition, config: config.join(definition, :right))
          end
        end

        # @api private
        def backend
          @backend ||= ROM::Schema::AssociationsDSL.new(source, inflector)
        end

        # @api private
        def source
          if provider.config.component.key?(:id)
            # TODO: decouple associations DSL from Relation::Name
            ROM::Relation::Name[
              provider.config.component.id, provider.config.component.dataset
            ]
          else
            config.source
          end
        end
      end
    end
  end
end
