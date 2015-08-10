require 'rom/sql/relation'

module ROM
  module SQL
    # A bunch of extensions that will be ported to other adapters
    #
    # @api public
    class Relation < ROM::Relation
      use :key_inference
      use :view
      use :auto_combine, adapter: :sql

      # @api private
      def self.inherited(klass)
        super
        klass.class_eval do
          auto_curry :for_wrap
        end
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
