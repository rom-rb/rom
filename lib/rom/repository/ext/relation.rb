require 'rom/relation/curried'

module ROM
  class Relation
    class Curried
      def columns
        relation.attributes(name)
      end
    end
  end
end
