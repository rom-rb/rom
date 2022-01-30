module Mappers
  module Users
    class Listing < ROM::Transformer
      config.component.id = :listing
      config.component.relation = :users
      config.component.namespace = "mappers.users"
    end
  end
end
