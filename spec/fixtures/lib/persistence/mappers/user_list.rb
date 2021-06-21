# frozen_string_literal: true

module Persistence
  module Mappers
    class UserList < ROM::Transformer
      relation :users
    end
  end
end
