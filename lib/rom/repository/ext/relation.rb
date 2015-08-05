module ROM
  module SQL
    class Relation < ROM::Relation
      class ViewDSL
        attr_reader :name

        attr_reader :attributes

        attr_reader :relation_block

        def initialize(name, &block)
          @name = name
          instance_eval(&block)
        end

        def header(attributes)
          @attributes = attributes
        end

        def relation(&block)
          @relation_block = lambda(&block)
        end

        def call
          [name, attributes, relation_block]
        end
      end

      def self.inherited(klass)
        super
        klass.class_eval do
          exposed_relations.merge(Set[:columns, :for_combine, :for_wrap])
          defines :attributes
          attributes({})

          option :attributes, reader: true, default: -> relation { relation.class.attributes }
        end
      end

      def self.view(*args, &block)
        name, names, relation_block =
          if block.arity == 0
            ViewDSL.new(*args, &block).call
          else
            [*args, block]
          end

        attributes[name] = names

        define_method(name, &relation_block)
      end

      def columns
        self.class.attributes.fetch(name, dataset.columns)
      end

      def for_combine(keys, relation)
        pk, fk = keys.to_a.flatten
        where(fk => relation.map { |tuple| tuple[pk] })
      end

      def for_wrap(name, keys)
        other = __registry__[name]

        inner_join(name, keys)
          .select(*qualified.header.columns)
          .select_append(*other.prefix(other.name).qualified.header)
      end

      def foreign_key
        :"#{Inflector.singularize(name)}_id"
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

      def foreign_key
        relation.foreign_key
      end
    end

    class Curried < Lazy
      def columns
        relation.attributes.fetch(options[:name], relation.columns)
      end
    end
  end
end
