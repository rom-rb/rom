module DataMapper
  module Relation

    # Implements renaming attributes and relations during relational
    # joins. Supports using either {Header::JoinStrategy::NaturalJoin}
    # or {Header::JoinStrategy::InnerJoin} strategies.
    class Header

      # Build a new {Header} instance
      #
      # @param [Symbol] relation_name
      #   the name of the relation
      #
      # @param [Enumerable<Symbol>] attribute_names
      #   the set of attribute names to build the index for
      #
      # @param [Class] strategy_class
      #   the strategy class to use for joining
      #
      # @return [Header]
      #
      # @api private
      def self.build(relation_name, attribute_names, strategy_class)
        a_idx = AttributeIndex.build(relation_name, attribute_names, strategy_class)
        r_idx = RelationIndex.build(a_idx)

        new(a_idx, r_idx)
      end

      include Enumerable, Adamantium, Equalizer.new(:attribute_index)

      # The aliases for renaming the right side relation after a {#join}
      #
      # @return [Hash<Symbol, Symbol>]
      #
      # @api private
      attr_reader :aliases

      # Initialize a new instance
      #
      # @param [AttributeIndex] attribute_index
      #   the attribute index used by this instance
      #
      # @param [RelationIndex] relation_index
      #   the relation index used by this instance
      #
      # @param [Hash<Symbol, Symbol>] aliases
      #   the aliases for the right side relation after a {#join}
      #
      # @return [undefined]
      #
      # @api private
      def initialize(attribute_index, relation_index, aliases = EMPTY_HASH)
        @attribute_index = attribute_index
        @relation_index  = relation_index

        @aliases = aliases
        @header  = @attribute_index.header
      end

      # Iterate over the header's attributes
      #
      # @yield [attribute]
      #
      # @yieldparam [Attribute] attribute
      #   a header attribute
      #
      # @return [self, Enumerator]
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        @header.each(&block)
        self
      end

      # Join self with +other+ using +join_definition+
      #
      # @param [Header] other
      #   the instance to join with self
      #
      # @param [#to_hash] join_definition
      #   the attributes to use for the join
      #
      # @return [Header]
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
      # @param [Hash<Symbol, Symbol>] aliases
      #   the aliases to use for renaming
      #
      # @return [Header]
      #
      # @api private
      def rename(aliases)
        new(attribute_index.rename_attributes(aliases), relation_index, aliases)
      end

      protected

      # The attribute index used by this instance
      #
      # @return [AttributeIndex]
      #
      # @api private
      attr_reader :attribute_index

      # The relation index used by this instance
      #
      # @return [RelationIndex]
      #
      # @api private
      attr_reader :relation_index

      # Rename the instance's attribute index relations
      #
      # @param [Hash<Symbol, Symbol>] aliases
      #   the aliases used to rename this instance's attribute index
      #
      # @return [AttributeIndex]
      #   the renamed attribute index
      #
      # @api private
      def rename_relations(aliases)
        attribute_index.rename_relations(aliases)
      end

      def relation_aliases(relation_index)
        self.relation_index.aliases(relation_index)
      end

      private

      def joined_relation_index(other)
        relation_index.join(other.relation_index)
      end

      def renamed_attribute_index(other, other_relation_index)
        other.rename_relations(other.relation_aliases(other_relation_index))
      end

      def new(*args)
        self.class.new(*args)
      end

    end # class Header

  end # module Relation
end # module DataMapper
