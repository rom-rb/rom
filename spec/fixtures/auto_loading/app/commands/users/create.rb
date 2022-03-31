# frozen_string_literal: true

module Commands
  module Users
    class Create < ROM::Memory::Commands::Create
      config.component.id = :create
      config.component.relation = :users
      config.component.namespace = "commands.users"
    end
  end
end
