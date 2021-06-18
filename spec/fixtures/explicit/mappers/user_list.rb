# frozen_string_literal: true

module Test
  module Mappers
    class UserList < ROM::Transformer
      relation :users
    end
  end
end
