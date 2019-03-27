# frozen_string_literal: true

require 'rom/relation/graph'
require 'rom/relation/commands'

module ROM
  class Relation
    # Represents a relation graphs which combines root relation
    # with other relation nodes
    #
    # @api public
    class Combined < Graph
      include Commands

      # Create a new relation combined with others
      #
      # @param [Relation] root
      # @param [Array<Relation>] nodes
      #
      # @return [Combined]
      #
      # @api public
      def self.new(root, nodes)
        root_ns = root.options[:struct_namespace]
        super(root, nodes.map { |node| node.struct_namespace(root_ns) })
      end

      # Combine this graph with more nodes
      #
      # @param [Array<Relation>] others A list of relations
      #
      # @return [Graph]
      #
      # @api public
      def combine_with(*others)
        self.class.new(root, nodes + others)
      end

      # Combine with other relations
      #
      # @see Relation#combine
      #
      # @return [Combined]
      #
      # @api public
      def combine(*args)
        self.class.new(root, nodes + root.combine(*args).nodes)
      end

      # Materialize combined relation
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        left = root.with(auto_map: false, auto_struct: false).call(*args)

        right =
          if left.empty?
            nodes.map { |node| Loaded.new(node, EMPTY_ARRAY) }
          else
            nodes.map { |node| node.call(left) }
          end

        if auto_map?
          Loaded.new(self, mapper.([left, right]))
        else
          Loaded.new(self, [left, right])
        end
      end

      # Return a new combined relation with adjusted node returned from a block
      #
      # @example with a node identifier
      #   combine(:tasks).node(:tasks) { |tasks| tasks.prioritized }
      #
      # @example with a nested path
      #   combine(tasks: :tags).node(tasks: :tags) { |tags| tags.where(name: 'red') }
      #
      # @param [Symbol] name The node relation name
      #
      # @yieldparam [Relation] relation The relation node
      # @yieldreturn [Relation] The new relation node
      #
      # @return [Relation]
      #
      # @api public
      def node(name, &block)
        if name.is_a?(Symbol) && !nodes.map { |n| n.name.key }.include?(name)
          raise ArgumentError, "#{name.inspect} is not a valid aggregate node name"
        end

        new_nodes = nodes.map { |node|
          case name
          when Symbol
            name == node.name.key ? yield(node) : node
          when Hash
            other, *rest = name.flatten(1)
            if other == node.name.key
              nodes.detect { |n| n.name.key == other }.node(*rest, &block)
            else
              node
            end
          else
            node
          end
        }

        with_nodes(new_nodes)
      end

      # Return a `:create` command that can insert data from a nested hash.
      #
      # This is limited to `:create` commands only, because automatic restriction
      # for `:update` commands would be quite complex. It's possible that in the
      # future support for `:update` commands will be added though.
      #
      # Another limitation is that it can only work when you're composing
      # parent and its child(ren), which follows canonical hierarchy from your
      # database, so that parents are created first, then their PKs are set
      # as FKs in child tuples. It should be possible to make it work with
      # both directions (parent => child or child => parent), and it would
      # require converting input tuples based on how they depend on each other,
      # which we could do in the future.
      #
      # Expanding functionality of this method is planned for rom 5.0.
      #
      # @see Relation#command
      #
      # @raise NotImplementedError when type is not `:create`
      #
      # @api public
      def command(type, *args)
        if type == :create
          super
        else
          raise NotImplementedError, "#{self.class}#command doesn't work with #{type.inspect} command type yet"
        end
      end

      private

      # @api private
      def decorate?(other)
        super || other.is_a?(Wrap)
      end
    end
  end
end
