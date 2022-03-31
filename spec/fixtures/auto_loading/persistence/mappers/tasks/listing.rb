# frozen_string_literal: true

module Persistence
  module Mappers
    module Tasks
      class Listing < ROM::Transformer
        config.component.id = :listing
        config.component.relation = :tasks
        config.component.namespace = "mappers.tasks"
      end
    end
  end
end
