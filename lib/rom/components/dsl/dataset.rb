# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # @private
      class Dataset < Core
        option :id

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
        def call(**options)
          components.replace(:datasets, id: id, provider: provider, block: block, **options)
        end
      end
    end
  end
end
