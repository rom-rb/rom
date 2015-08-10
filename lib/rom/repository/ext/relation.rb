require 'rom/relation'

module ROM
  module SQL
    # A bunch of extensions that will be ported to other adapters
    #
    # @api public
    class Relation < ROM::Relation
      use :view

      # @api private
      def self.inherited(klass)
        super
        klass.class_eval do
          auto_curry :for_combine
          auto_curry :for_wrap
        end
      end

      # Default methods for fetching combined relation
      #
      # This method is used by default by `combine`
      #
      # @return [SQL::Relation]
      #
      # @api private
      def for_combine(keys, relation)
        pk, fk = keys.to_a.flatten
        where(fk => relation.map { |tuple| tuple[pk] })
      end

      # Default methods for fetching wrapped relation
      #
      # This method is used by default by `wrap` and `wrap_parents`
      #
      # @return [SQL::Relation]
      #
      # @api private
      def for_wrap(keys, name)
        other = __registry__[name]

        inner_join(name, keys)
          .select(*qualified.header.columns)
          .select_append(*other.prefix(other.name).qualified.header)
      end

      # Infer foreign_key name for this relation
      #
      # TODO: this should be configurable and handled by an injected policy
      #
      # @return [Symbol]
      #
      # @api private
      def foreign_key
        :"#{Inflector.singularize(name)}_id"
      end

      def base_name
        name
      end
    end
  end

  class Relation
    class Curried
      def columns
        relation.attributes.fetch(name, relation.columns)
      end
    end
  end
end
