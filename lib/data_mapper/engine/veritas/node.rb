module DataMapper
  class Engine
    module Veritas

      # Relation node wrapping veritas relation
      #
      class Node < Relation::Graph::Node
        include Enumerable

        # Renames the relation with given aliases
        #
        # @example
        #
        #   renamed = DataMapper.engines[:default].relations[:people].rename(:id => :person_id)
        #
        # @param [Relation::Graph::Node::Aliases]
        #
        # @return [Node]
        #
        # @api public
        def rename(new_aliases)
          renamed_aliases  = aliases.rename(new_aliases)
          renamed_relation = relation.rename(renamed_aliases)

          self.class.new(name, renamed_relation, renamed_aliases)
        end

        # Joins two nodes
        #
        # @example
        #
        #   people    = DataMapper.engines[:default].relations[:people]
        #   addresses = DataMapper.engines[:default].relations[:addresses]
        #
        #   joined = people.join(addresses)
        #
        # @param [Node]
        #
        # @return [Node]
        #
        # @api public
        def join(other, join_definition = {})
          joined_aliases  = aliases.join(other.aliases, join_definition)
          joined_relation = join_relation(other, joined_aliases)

          self.class.new(name, joined_relation, joined_aliases)
        end

        # Returns header for the veritas relation
        #
        # @return [::Veritas::Header]
        #
        # @api private
        def header
          relation.header
        end

        # Restricts the relation and returns new node
        #
        # @example
        #
        #   restricted = DataMapper.engines[:default].relations[:people].restrict { |r|
        #     r.name.eq('John)
        #   }
        #
        # @param [*args] anything that Veritas::Relation::Base#restrict accepts
        #
        # @param [Proc]
        #
        # @return [Node]
        #
        # @api public
        def restrict(*args, &block)
          self.class.new(name, relation.restrict(*args, &block), aliases)
        end

        # Sorts the relation and returns new node
        #
        # @example
        #
        #   ordered = DataMapper.engines[:default].relations[:people].order(:name)
        #
        # @param [*attributes]
        #
        # @return [Node]
        #
        # @api public
        def order(*attributes)
          sorted = relation.sort_by { |r| attributes.map { |attribute| r.send(attribute) } }
          self.class.new(name, sorted, aliases)
        end

        # Sorts relation and returns new node
        #
        # @example
        #
        #   sorted = DataMapper.engines[:default].relations[:people].sort_by { |r|
        #     [ r.name.desc ]
        #   }
        #
        # @param [Proc]
        #
        # @return [Node]
        #
        # @api public
        def sort_by(&block)
          self.class.new(name, relation.sort_by(&block), aliases)
        end

        private

        def join_relation(other, joined_aliases)
          relation.rename(joined_aliases).join(other.relation)
        end

      end # class Node

    end # module Veritas
  end # class Engine
end # module DataMapper
