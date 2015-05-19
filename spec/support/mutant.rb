module Mutant
  class Selector
    # Expression based test selector
    class Expression < self
      def call(_subject)
        integration.all_tests
      end
    end # Expression
  end # Selector
end # Mutant
