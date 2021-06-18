# frozen_string_literal: true

module My
  module NewNamespace
    module Foo
      class CustomerList < ROM::Transformer
        relation :customers
      end
    end
  end
end
