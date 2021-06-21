# frozen_string_literal: true

module MyCommands
  class CreateUser < ROM::Memory::Commands::Create
    relation :users
  end
end
