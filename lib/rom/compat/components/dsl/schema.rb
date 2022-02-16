# frozen_string_literal: true

require "rom/relation/name"

require "rom/components/dsl/schema"
require "rom/compat/schema/dsl"

module ROM
  module Components
    module DSL
      # @private
      #
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      class Schema < Core
        mod = Module.new do
          # @api private
          def call
            return super unless config.dsl_class || config.view

            configure

            if config.view
              components.add(key, name: name, config: config, block: block)
            else
              dsl_config = backend.config
              associations = dsl_config[:associations]

              component = components.add(key, name: name, config: config.join(dsl_config, :right))

              associations.each do |definition|
                components.add(
                  :associations,
                  definition: definition,
                  config: dsl_assoc_config.join({namespace: relation, **definition.to_h}, :right)
                )
              end

              component
            end
          end

          # @api public
          #
          # @deprecated
          def associations(&block)
            backend.associations(&block)
          end

          private

          # @api private
          def name
            ROM::Relation::Name[relation, config.dataset]
          end

          # @api private
          def dsl_assoc_config
            provider.config.association.merge(adapter: adapter, inflector: inflector)
          end

          # @api private
          def backend
            @backend ||= config.dsl_class.new(
              **config,
              attributes: attributes,
              inferrer: inferrer,
              inflector: inflector,
              plugins: config.plugins,
              relation: name,
              definition: block
            )
          end

          # @api private
          def configure
            if !config.view && provider.config.component.type == :relation
              provider.config.component.update(dataset: config.dataset) if config.dataset
              provider.config.component.update(id: config.as) if config.as

              if provider.config.component.id == :anonymous
                provider.config.component.update(id: config.id)
              end

              if config.id.nil?
                config.update(id: provider.config.component.id)
              end

              if config.relation.nil?
                config.update(relation: provider.config.component.id)
              end

              if config.adapter.nil?
                config.update(adapter: provider.config.component.adapter)
              end
            end

            config.update(id: relation) if relation && (config.id.nil? || config.as)

            if provider.config.component.type == :relation
              provider.config.component.inherit!(config)
            end

            if config.view
              config.join!({namespace: relation}, :right)
            end

            super
          end

          # @api private
          def relation
            config.relation || config.as || config.id
          end

          # @api private
          def inferrer
            config.inferrer.with(enabled: config.infer)
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity

        prepend(mod)
      end
    end
  end
end
