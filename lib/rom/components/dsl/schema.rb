# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # @private
      class Schema < Core
        key :schemas

        # TODO: move to rom/compat
        # @private
        def call
          if !config.view
            if provider.config.component.type == :relation
              provider.config.component.update(dataset: config.id) if config.id
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
          end

          config.update(as: relation, relation: relation) if relation

          provider.config.component.inherit!(config) if provider.config.component.type == :relation

          super
        end

        # @api private
        def relation
          config.relation || config.as || config.id
        end
      end
    end
  end
end
