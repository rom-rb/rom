require 'rom/relation/graph'

module ROM
  class Relation
    # Relation wrapping other relations
    #
    # @api public
    class Wrap < Graph
      extend Initializer

      include Materializable
      include Pipeline
      include Pipeline::Proxy

      param :root
      param :nodes

      alias_method :left, :root
      alias_method :right, :nodes

      # @api public
      def wrap(*args)
        self.class.new(root, nodes + root.wrap(*args).nodes)
      end

      # @see Relation#call
      #
      # @api public
      def call(*args)
        if auto_map?
          Loaded.new(self, mapper.(relation.with(auto_struct: false)))
        else
          Loaded.new(self, relation.(*args))
        end
      end

      # @api private
      def relation
        raise NotImplementedError
      end

      # @api private
      def to_ast
        @__ast__ ||= [:relation, [name.relation, attr_ast + nodes_ast, meta_ast]]
      end

      # @api private
      def attr_ast
        root.attr_ast
      end

      # @api private
      def nodes_ast
        nodes.map(&:to_ast)
      end

      # Return if this is a wrap relation
      #
      # @return [true]
      #
      # @api private
      def wrap?
        true
      end
    end
  end
end
