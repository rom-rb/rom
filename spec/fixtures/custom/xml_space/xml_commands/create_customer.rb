# frozen_string_literal: true

module XMLSpace
  module XMLCommands
    class CreateCustomer < ROM::Memory::Commands::Create
      relation :customers
    end
  end
end
