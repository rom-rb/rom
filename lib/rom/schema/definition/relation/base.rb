module ROM
  class Schema
    class Definition
      class Relation

        class Base < self

          attr_reader :repository

          def repository(name)
            @repository = name
          end

        end # Base

      end # Relation
    end # Definition
  end # Schema
end # ROM
