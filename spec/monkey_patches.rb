module Veritas
  class Relation

    class Gateway < Relation
      undef_method :to_set if method_defined?(:to_set)
    end
  end
end
