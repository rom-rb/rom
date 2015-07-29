module ROM
  module SQL
    class Relation < ROM::Relation
      # TODO: This will go away when ROM core generates Lazy classes dedicated for each
      # relation class and by adding configuration for the query interface which
      # could be easily exposed by lazy relations for cases like repository
      def self.inherited(klass)
        super
        klass.exposed_relations << :columns << :select << :order << :where << :primary_key << :foreign_key << :for_combine
      end

      def for_combine(relation)
        primary_key = relation.source.primary_key
        foreign_key = relation.source.foreign_key

        where(foreign_key => relation.map { |tuple| tuple[primary_key] })
      end

      # TODO: this should be an injectible strategy so we can easily configure it
      def foreign_key
        :"#{Inflector.singularize(name)}_id"
      end
    end
  end

  # TODO: consider moving this to rom core
  class Relation
    class Lazy
      # TODO: this will go away when Lazy exposes the whole query interface
      undef_method :select # Object#select bites me once again

      def base_name
        relation.name
      end
    end

    class Curried < Lazy
      def columns
        relation.columns
      end
    end
  end
end
