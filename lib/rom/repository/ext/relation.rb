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
      use :auto_wrap, adapter: :sql
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
