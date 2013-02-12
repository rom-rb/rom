module DataMapper
  module Relation
    class Graph

      # Represents a relation in the registry graph
      #
      class Node
        include Enumerable, Equalizer.new(:name)

        # Build a new {Header} instance
        #
        # @param [Symbol] relation_name
        #   the name of the relation
        #
        # @param [Enumerable<Symbol>] attribute_names
        #   the set of attribute names to build the index for
        #
        # @return [Header]
        #
        # @api private
        def self.header(relation_name, attribute_names)
          Header.build(relation_name, attribute_names, join_strategy)
        end

        # The strategy to use for header aliasing when joining headers
        #
        # @return [Header::JoinStrategy::NaturalJoin]
        #
        # @api private
        def self.join_strategy
          Header::JoinStrategy::NaturalJoin
        end

        private_class_method :join_strategy

        # The node name
        #
        # @example
        #
        #   node = Node.new(:name)
        #   node.name
        #
        # @return [Symbol]
        #
        # @api public
        attr_reader :name

        # Instance of the engine's relation class
        #
        # @return [Object]
        #
        # @api private
        attr_reader :relation

        # Header for this relation
        #
        # @return [Header]
        #
        # @api private
        attr_reader :header

        # Initializes a relation node instance
        #
        # @param [#to_sym] name
        #   the name for the node
        #
        # @param [Object] relation
        #   an instance of the engine's relation class
        #
        # @param [Header] header
        #   the header to use for this node
        #
        # @return [undefined]
        #
        # @api private
        def initialize(name, relation, header = EMPTY_HASH)
          @name     = name.to_sym
          @relation = relation
          @header   = header
        end

        # Iterate on relation
        #
        # @example
        #
        #   DataMapper.engines[:default].relations[:people].each do |tuple|
        #     puts tuple.inspect
        #   end
        #
        # @return [self, Enumerator]
        #
        # @yield [Object]
        #
        # @api public
        def each(&block)
          return to_enum unless block_given?
          @relation.each(&block)
          self
        end

        # Adds new object to the relation
        #
        # @example
        #
        #   tuple = { :name => 'John' }
        #   DataMapper.engines[:postgres].relations[:people].insert(tuple)
        #
        # @param [Object]
        #
        # @api public
        def insert(tuple)
          @relation.insert(tuple)
        end
        alias_method :<<, :insert

        # Updates an object identified with the given key from the relation
        #
        # @example
        #
        #   DataMapper.engines[:postgres].relations[:people].update(1, name: 'John')
        #
        # @param [Object] key attribute
        # @param [Object] tuple
        #
        # @api public
        def update(key, tuple)
          @relation.update(key, tuple)
        end

        # Deletes an object identified with the given key from the relation
        #
        # @example
        #
        #   DataMapper.engines[:postgres].relations[:people].delete(1)
        #
        # @param [Object] key attribute
        #
        # @api public
        def delete(key)
          @relation.delete(key)
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
        def join(other, join_definition = EMPTY_HASH)
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
        # @param [*args] args
        #   the directions used for sorting the relation
        #
        # @param [Proc] &block
        #   the optional block to evaluate for directions
        #
        # @return [Node]
        #
        # @api public
        def sort_by(*args, &block)
          new(name, relation.sort_by(*args, &block), header)
        end

        # Sorts relation ascending using the complete header
        #
        # TODO think more about this and/or refactor
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

        def new(*args)
          self.class.new(*args)
        end

      end # class Node

    end # class Graph
  end # module Relation
end # module DataMapper
