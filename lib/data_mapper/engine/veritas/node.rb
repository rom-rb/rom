require 'veritas'

module DataMapper
  class Engine
    module Veritas

      # Relation node wrapping veritas relation
      #
      class Node < Relation::Graph::Node
        include Enumerable

        # Iterates over relation tuples
        #
        # @example
        #
        #   DataMapper.engines[:default].relations[:people].each do |tuple|
        #     puts tuple.inspect
        #   end
        #
        # @return [self] if a block was passed in
        # @return [Enumerator] otherwise
        #
        # @yield [::Veritas::Tuple]
        #
        # @api public
        def each(&block)
          return to_enum unless block_given?
          relation.each(&block)
          self
        end

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
          self.class.new(name, relation, aliases.merge(new_aliases))
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
        def join(other, *)
          self.class.new(name, relation.rename(aliases).join(other.aliased.relation))
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

      end # class Node

    end # module Veritas
  end # class Engine
end # module DataMapper
