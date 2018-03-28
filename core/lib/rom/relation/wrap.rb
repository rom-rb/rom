require 'rom/relation/graph'
require 'rom/relation/combined'

module ROM
  class Relation
    # Relation wrapping other relations
    #
    # @api public
    class Wrap < Graph
      # Wrap more relations
      #
      # @see Relation#wrap
      #
      # @return [Wrap]
      #
      # @api public
      def wrap(*args)
        self.class.new(root, nodes + root.wrap(*args).nodes)
      end

      # Materialize a wrap
      #
      # @see Relation#call
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        if auto_map?
          Loaded.new(self, mapper.(relation.with(auto_map: false, auto_struct: false)))
        else
          Loaded.new(self, relation.(*args))
        end
      end

      # Return an adapter-specific relation representing a wrap
      #
      # @abstract
      #
      # @api private
      def relation
        raise NotImplementedError
      end

      # Return if this is a wrap relation
      #
      # @return [true]
      #
      # @api private
      def wrap?
        true
      end

      private

      # @api private
      def decorate?(other)
        super || other.is_a?(Combined)
      end
    end
  end
end
