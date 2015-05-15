module Mutant
  class Selector
    # Expression based test selector
    class Expression < self
      def call(subject)
        integration.all_tests
      end
    end # Expression
  end # Selector
end # Mutant
