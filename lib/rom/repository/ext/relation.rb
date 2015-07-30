module ROM
  module SQL
    class Relation < ROM::Relation
      def self.inherited(klass)
        super
        klass.exposed_relations.merge(Set[:columns, :for_combine])
      end

      def for_combine(keys, relation)
        custom_meth = :"for_#{relation.source.name}"

        if respond_to?(custom_meth)
          __send__(custom_meth, relation)
        else
          pk, fk = keys.to_a.flatten
          where(fk => relation.map { |tuple| tuple[pk] })
        end
      end
    end
  end

  class Relation
    class Lazy
      def base_name
        relation.name
      end

      def columns
        relation.columns
      end

      def primary_key
        relation.primary_key
      end
    end
  end
end
