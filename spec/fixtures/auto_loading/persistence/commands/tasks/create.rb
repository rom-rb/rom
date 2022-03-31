# frozen_string_literal: true

module Persistence
  module Commands
    module Tasks
      class Create < ROM::Memory::Commands::Create
        config.component.id = :create
        config.component.relation = :tasks
        config.component.namespace = "commands.tasks"
      end
    end
  end
end
