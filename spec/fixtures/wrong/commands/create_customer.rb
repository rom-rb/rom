# frozen_string_literal: true

module My
  module NewNamespace
    module Foo
      class CreateCustomer < ROM::Memory::Commands::Create
        relation :users
      end
    end
  end
end
