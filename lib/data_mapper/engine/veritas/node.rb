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
        def rename(aliases)
          renamed_header   = header.rename(aliases)
          renamed_relation = relation.rename(renamed_header.aliases)

          new(name, renamed_relation, renamed_header)
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
          joined_header   = header.join(other.header, join_definition)
          joined_relation = join_relation(other, joined_header)

          new(name, joined_relation, joined_header)
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
          new(name, relation.restrict(*args, &block), header)
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
          new(name, sorted, header)
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
          new(name, relation.sort_by(&block), header)
        end

        # Sorts relation ascending using the complete header
        #
        # TODO think more about this and/or refactor + implement for arel
        #
        # @example
        #
        #   sorted = DataMapper.engines[:default].relations[:people].ordered
        #
        # @return [Node]
        #
        # @api public
        def ordered
          new(name, relation.sort_by(relation.header), header)
        end

        private

        def join_relation(other, joined_header)
          relation.join(other.relation.rename(joined_header.aliases))
        end

      end # class Node

    end # module Veritas
  end # class Engine
end # module DataMapper
