module Mutant
  class Subject
    def tests
      config.integration.all_tests
    end
  end
end
