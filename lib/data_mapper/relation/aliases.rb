module DataMapper
  module Relation

    class Aliases

      # Build a new {Aliases} instance
      #
      # @param [Symbol] relation_name
      #   the name of the relation
      #
      # @param [AttributeSet] attribute_set
      #   the set of attributes to build the index for
      #
      # @param [Class] strategy_class
      #   the strategy class to use for joining
      #
      # @return [Aliases]
      #
      # @api private
      def self.build(relation_name, attribute_set, strategy_class)
        a_idx = AttributeIndex.build(relation_name, attribute_set, strategy_class)
        r_idx = RelationIndex.build(a_idx)

        new(a_idx, r_idx)
      end

      include Enumerable
      include Equalizer.new(:attribute_index)

      # The header represented by this instance
      #
      # @return [Set<Attribute>]
      #
      # @api private
      attr_reader :header

      # Initialize a new instance
      #
      # @param [AttributeIndex] attribute_index
      #   the attribute index used by this instance
      #
      # @param [Hash] aliases
      #   the aliases used by this instance
      #
      # @return [undefined]
      #
      # @api private
      def initialize(attribute_index, relation_index, aliases = {})
        @attribute_index = attribute_index
        @relation_index  = relation_index

        @aliases = aliases
        @header  = @attribute_index.header
      end

      # Iterate over the aliases
      #
      # If this instance has previously been joined with another one,
      # the yielded aliases are to be used for renaming the right side
      # relation of the relational join.
      #
      # @yield [old, new]
      #
      # @yieldparam [Symbol] old
      #   the old attribute name
      #
      # @yieldparam [Symbol] new
      #   the new attribute name
      #
      # @return [self, Enumerator]
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        @aliases.each(&block)
        self
      end

      # Join self with +other+ using +join_definition+
      #
      # @param [Aliases] other
      #   the instance to join with self
      #
      # @param [#to_hash] join_definition
      #   the attributes to use for the join
      #
      # @return [Aliases]
      #
      # @api private
      def join(other, join_definition)
        joined_r_idx  = joined_relation_index(other)
        renamed_a_idx = renamed_attribute_index(other, joined_r_idx)
        joined_a_idx  = attribute_index.join(renamed_a_idx, join_definition)
        other_aliases = renamed_a_idx.aliases(joined_a_idx)

        new(joined_a_idx, joined_r_idx, other_aliases)
      end

      # Rename this instance
      #
      # @param [Hash] aliases
      #   the aliases to use for renaming
      #
      # @return [Aliases]
      #
      # @api private
      def rename(aliases)
        new(attribute_index.rename(aliases), relation_index, aliases)
      end

      protected

      # The index used by this instance
      #
      # @return [AttributeIndex]
      #
      # @api private
      attr_reader :attribute_index

      # Return the relation alias index
      #
      # @return [RelationIndex]
      #
      # @api private
      attr_reader :relation_index

      # Rename the indexed relations
      #
      # @param [Hash<Symbol, Symbol>] aliases
      #   the aliases used to rename this index's instance
      #
      # @return [AttributeIndex]
      #   the renamed attribute index
      #
      # @api private
      def rename_relations(aliases)
        attribute_index.rename_relations(aliases)
      end

      private

      def joined_relation_index(other)
        relation_index.join(other.relation_index)
      end

      def renamed_attribute_index(other, other_relation_index)
        other.rename_relations(relation_aliases(other, other_relation_index))
      end

      def relation_aliases(other, other_relation_index)
        other.relation_index.aliases(other_relation_index)
      end

      def new(*args)
        self.class.new(*args)
      end

    end # class Aliases

  end # module Relation
end # module DataMapper
