module DataMapper
  module Relation

    class Aliases

      def self.index_entries(relation_name, attribute_set)
        attribute_set.primitives.each_with_object({}) { |attribute, hash|
          attribute = Attribute.build(attribute.field, relation_name)
          hash[attribute] = attribute
        }
      end

      include Enumerable
      include Equalizer.new(:index)

      attr_reader :index
      attr_reader :header

      protected :index

      def initialize(index, aliases = {})
        @index   = index
        @aliases = aliases
        @header  = @index.header
      end

      def each(&block)
        return to_enum unless block_given?
        @aliases.each(&block)
        self
      end

      def join(other, join_definition)
        joined_index = index.join(other.index, join_definition)
        new(joined_index, other.index.aliases(joined_index))
      end

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
