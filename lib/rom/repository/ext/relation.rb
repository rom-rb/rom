require 'rom/relation/curried'

module ROM
  class Relation
    class Curried
      def columns
        relation.attributes.fetch(name, relation.columns)
      end
    end
  end
end
