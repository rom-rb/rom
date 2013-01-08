module DataMapper
  module Relation
    class Aliases

      class RelationIndex

        # Build a new {RelationIndex} instance
        #
        # @param [AttributeIndex] attribute_index
        #   the attribute index used to build the relation index
        #
        # @return [RelationIndex]
        #
        # @api private
        def self.build(attribute_index)
          new(initial_entries(attribute_index))
        end

        # Return index entries as required by {RelationIndex#initialize}
        #
        # @param [AttributeIndex] attribute_index
        #   the attribute index used to build the relation index
        #
        # @return [Hash<Symbol, Integer>]
        #
        # @api private
        def self.initial_entries(attribute_index)
          attribute_index.entries.each_with_object({}) { |(initial, _), entries|
            entries[initial.prefix] = 1
          }
        end

        private_class_method :initial_entries

        # Initialize a new instance
        #
        # @param [Hash<Symbol, Integer>] entries
        #   the entries to manage
        #
        # @return [undefined]
        #
        # @api private
        def initialize(entries)
          @entries        = entries
          @relation_names = @entries.keys
        end

        # Join this instance with another one
        #
        # @param [RelationIndex] other
        #   the other relation index to join with self
        #
        # @return [RelationIndex]
        #
        # @api private
        def join(other)
          new(entries.merge(other.entries) { |key, old, new| old + new })
        end

        # Rename relations indexed by this instance
        #
        # @param [Hash<Symbol, Symbol>] aliases
        #   the aliases to use for renaming
        #
        # @return [RelationIndex]
        #
        # @api private
        def rename(aliases)
          new(aliases.each_with_object(entries.dup) { |(old, new), new_entries|
            new_entries[new] = new_entries.delete(old)
          })
        end

        # The aliases needed to mimic +other+
        #
        # @param [RelationIndex] other
        #   the other index to calculate aliases for
        #
        # @return [Hash<Symbol, Symbol>
        #
        # @api private
        def aliases(other)
          common_names(other).each_with_object({}) { |name, aliases|
            left, right   = fetch(name), other.fetch(name)
            aliases[name] = :"#{name}_#{right}" if left != right
          }
        end

        protected

        # The entries managed by this instance
        #
        # @return [Hash<Symbol, Integer>]
        #
        # @api private
        attr_reader :entries

        # Return the relation names indexed by this instance
        #
        # @return [Array<Symbol>]
        #
        # @api private
        attr_reader :relation_names

        # Return the current relation count for the given +relation_name+
        #
        # @param [Symbol] relation_name
        #   the relation name used to get the count
        #
        # @return [Integer]
        #   the current relation count if the given +relation_name+ was found
        #
        # @raise [KeyError]
        #   if +relation_name+ isn't indexed by this instance
        #
        # @api private
        def fetch(relation_name)
          entries.fetch(relation_name)
        end

        private

        def common_names(other)
          @relation_names & other.relation_names
        end

        def new(*args)
          self.class.new(*args)
        end
      end

    end # class Aliases
  end # module Relation
end # module DataMapper
