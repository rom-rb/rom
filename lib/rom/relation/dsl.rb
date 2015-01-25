module ROM
  class Relation
    module DSL
      def self.included(klass)
        klass.extend(ClassMacros)
      end
    end
  end
end
