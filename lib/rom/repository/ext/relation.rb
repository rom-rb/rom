module ROM
  module SQL
    class Relation < ROM::Relation
      def self.inherited(klass)
        super
        klass.class_eval do
          exposed_relations.merge(Set[:columns, :for_combine, :for_wrap])
          defines :attributes
          attributes({})

          option :attributes, reader: true, default: -> relation { relation.class.attributes }
        end
      end

      def self.view(name, names, &block)
        attributes[name] = names
        define_method(name, &block)
      end

      def columns
        self.class.attributes.fetch(name, dataset.columns)
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

      def for_wrap(name, keys)
        other = __registry__[name]

        inner_join(name, keys)
          .select(*qualified.header.columns)
          .select_append(*other.prefix(other.name).qualified.header)
      end
    end
  end

  class Relation
    class Lazy
      def base_name
        relation.name
      end

      def primary_key
        relation.primary_key
      end
    end

    class Curried < Lazy
      def columns
        relation.attributes.fetch(options[:name], relation.columns)
      end
    end
  end
end
