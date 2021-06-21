# frozen_string_literal: true

module Test
  module Commands
    class CreateUser < ROM::Memory::Commands::Create
      relation :users
    end
  end
end
