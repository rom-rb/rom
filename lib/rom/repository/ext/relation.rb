require 'rom/relation/curried'

module ROM
  class Relation
    class Curried
      def attributes(view_name = name)
        relation.attributes(view_name)
      end
    end
  end
end
