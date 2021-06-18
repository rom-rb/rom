# frozen_string_literal: true

module XMLSpace
  module XMLMappers
    class CustomerList < ROM::Transformer
      relation :customers
    end
  end
end
