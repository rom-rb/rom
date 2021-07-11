# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # @private
      class Dataset < Core
        key :datasets

        option :id

        option :gateway, default: -> { resolve_gateway }

        option :abstract, default: -> { id.nil? }

        # Set or get custom dataset block
        #
        # This block will be evaluated when a relation is instantiated and registered
        # in a relation registry.
        #
        # @example
        #   class Users < ROM::Relation[:memory]
        #     dataset { sort_by(:id) }
        #   end
        #
        # @api public
        def call
          add(provider: owner)
        end

        private

        # @api private
        def resolve_gateway
          config.component.gateway
        end
      end
    end
  end
end
