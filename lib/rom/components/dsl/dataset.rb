# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # @private
      class Dataset < Core
        key :datasets

        def configure
          if relation?
            config.join!({namespace: relation_id}, :right) if config.id != relation_id

            config.relation_id = relation_id
          end
          super
        end

        private

        def relation_id
          provider.config.component.id
        end

        def relation?
          provider.config.component.type == :relation
        end
      end
    end
  end
end
