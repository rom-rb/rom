require 'rom/relation'
require 'rom/repository/ext/relation/view_dsl'

module ROM
  module SQL
    # A bunch of extensions that will be ported to other adapters
    #
    # @api public
    class Relation < ROM::Relation
      # @api private
      def self.inherited(klass)
        super
        klass.class_eval do
          defines :attributes
          attributes({})

          option :attributes, reader: true, default: -> relation { relation.class.attributes }

          auto_curry :for_combine
          auto_curry :for_wrap
        end
      end

      # Define a relation view with a specific header
      #
      # With headers defined all the mappers will be inferred automatically
      #
      # @example
      #   class Users < ROM::Relation[:sql]
      #     view(:by_name, [:id, :name]) do |name|
      #       where(name: name)
      #     end
      #
      #     view(:listing, [:id, :name, :email]) do
      #       select(:id, :name, :email).order(:name)
      #     end
      #   end
      #
      # @api public
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

      # Return column names that will be selected for this relation
      #
      # By default we use dataset columns but first we look at configured
      # attributes by `view` DSL
      #
      # @return [Array<Symbol>]
      #
      # @api private
      def columns
        self.class.attributes.fetch(name, dataset.columns)
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
      def for_wrap(name, keys)
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
