# frozen_string_literal: true

module Test
  module MyMappers
    class UserList < ROM::Transformer
      relation :users
    end
  end
end
