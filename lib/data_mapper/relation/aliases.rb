module DataMapper
  module Relation

    class Aliases

      InvalidRelationAliasError = Class.new(StandardError)

      # Return index entries as required by {Aliases#initialize}
      #
      # @param [#to_sym] relation_name
      #   the name of the relation +attribute_set+ belongs to
      #
      # @param [DataMapper::Mapper::AttributeSet] attribute_set
      #   the attribute set to be aliased
      #
      # @return [Hash<Attribute, Attribute>]
      #
      # @api private
      def self.index_entries(relation_name, attribute_set)
        attribute_set.primitives.each_with_object({}) { |attribute, entries|
          attribute = Attribute.build(attribute.field, relation_name)
          entries[attribute] = attribute
        }
      end

      include Enumerable
      include Equalizer.new(:index)

      # The index used by this instance
      #
      # @return [Index]
      #
      # @api private
      attr_reader :index

      # The header represented by this instance
      #
      # @return [Set<Attribute>]
      #
      # @api private
      attr_reader :header

      protected :index

      # Initialize a new instance
      #
      # @param [Index] index
      #   the index used by this instance
      #
      # @param [Hash] aliases
      #   the aliases used by this instance
      #
      # @return [undefined]
      #
      # @api private
      def initialize(index, aliases = {})
        @index   = index
        @aliases = aliases
        @header  = @index.header
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
      # @param [Relationship::JoinDefinition] join_definition
      #   the attributes to use for the join
      #
      # @return [Aliases]
      #
      # @api private
      def join(other, join_definition, relation_aliases = {})
        joined = index.join(other.index, join_definition, relation_aliases)
        new(joined, other.index.aliases(joined))
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
        new(index.rename(aliases), aliases)
      end

      private

      def new(*args)
        self.class.new(*args)
      end

    end # class Aliases

  end # module Relation
end # module DataMapper
