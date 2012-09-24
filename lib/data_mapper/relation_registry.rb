module DataMapper

  # RelationRegistry
  #
  class RelationRegistry

    class Node

      def self.new(relation)
        return super if self < Node
        klass = relation.respond_to?(:name) ? Base : self
        klass.new(relation)
      end

      class Base < self

        attr_reader :name

        def initialize(relation)
          super
          @name = relation.name.to_sym
        end
      end

      attr_reader :relation
      attr_reader :connectors
      attr_reader :edges

      def initialize(relation)
        @relation   = relation
        @connectors = {}
        @edges      = Set.new
      end

      def [](name)
        @connectors[name]
      end

      def add_edge(edge, name = nil)
        if name
          if existing_edge = find_edge(edge)
            @connectors[name] = existing_edge
            return self
          else
            @connectors[name] = edge
          end
        end

        @edges << edge

        self
      end

      def hash
        @relation.hash
      end

      def eql?(other)
        instance_of?(other.class) && @relation.eql?(other.relation)
      end

      def ==(other)
        return false unless self.class <=> other.class
        @relation == other.relation
      end

      private

      def find_edge(edge)
        @edges.detect { |e| e == edge }
      end

    end # class Node

    class Edge

      Relation = Struct.new(:relation, :op_attributes)

      def self.op
        :join
      end

      attr_reader :a
      attr_reader :b
      attr_reader :relations
      attr_reader :op

      def initialize(a, b, op = self.class.op)
        @a = a
        @b = b
        @relations  = Set[@a, @b]
        @op = op
      end

      def hash
        @relations.hash
      end

      def eql?(other)
        instance_of?(other.class) && @relations.eql?(other.relations)
      end

      def ==(other)
        return false unless self.class <=> other.class
        @relations == other.relations
      end
    end # class Edge

    attr_reader :nodes

    def initialize
      @index = {}
      @nodes = Set.new
    end

    def edges
      @nodes.each_with_object(Set.new) { |node, edges|
        edges.merge(node.edges)
      }
    end

    def add_edge(name, source, target)
      source_node = node_for(source.relation)
      target_node = node_for(target.relation)

      edge = Edge.new(source, target)

      source_node.add_edge(edge, name)
      target_node.add_edge(edge)

      self
    end

    def node_for(relation)
      if relation.respond_to?(:name)
        @index[relation.name.to_sym]
      else
        @nodes.detect { |node| node.relation == relation }
      end
    end

    def <<(relation)
      node = Node.new(relation)

      @nodes << node
      if node.respond_to?(:name)
        @index[node.name] = node
      end

      relation
    end

    def node(name)
      @index[name.to_sym]
    end

    def [](name)
      node(name).relation
    end

  end # class RelationRegistry
end # module DataMapper
