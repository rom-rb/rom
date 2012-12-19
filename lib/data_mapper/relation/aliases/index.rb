module DataMapper
  module Relation
    class Aliases

      class Index

        include Equalizer.new(:entries)

        # The entries managed by this instance
        #
        # @return [Hash<Attribute, Attribute>]
        #
        # @api private
        attr_reader :entries

        # The header represented by this instance
        #
        # @return [Set<Attribute>]
        #
        # @api private
        attr_reader :header

        # Initialize a new instance
        #
        # @param [Hash<Attribute, Attribute>] entries
        #   the entries to manage
        #
        # @param [Strategy] strategy
        #   the strategy to use for {#join}
        #
        # @return [undefined]
        #
        # @api private
        def initialize(entries, strategy)
          @entries  = entries
          @inverted = @entries.invert
          @header   = @entries.values.to_set
          @strategy = strategy.new(self)
        end

        # Join this instance with another one
        #
        # @see Strategy#join
        #
        # @param [args]
        #   the arguments accepted by {Strategy#join}
        #
        # @return [Index]
        #
        # @api private
        def join(*args)
          @strategy.join(*args)
        end

        # Rename this instance
        #
        # @param [Hash<Symbol, Symbol>] aliases
        #   the aliases to use for renaming
        #
        # @return [Index]
        #
        # @api private
        def rename(aliases)
          self.class.new(renamed_entries(aliases), @strategy.class)
        end

        # The aliases needed to mimic +other+
        #
        # @param [Index] other
        #   the other index to calculate aliases for
        #
        # @return [Hash<Symbol, Symbol>
        #
        # @api private
        def aliases(other)
          entries.each_with_object({}) { |(key, name), aliases|
            other_name = other[key].name
            if name.field != other_name
              aliases[name.field] = other_name
            end
          }
        end

        # Return the current {Attribute} for the given +key+
        #
        # @param [Attribute] key
        #   the original attribute
        #
        # @return [Attribute]
        #   the current {Attribute} if the given +key+ was found
        #
        # @return [nil]
        #   otherwise
        #
        # @api private
        def [](key)
          entries[key]
        end

        # Tests wether this instance contains the given +field+
        #
        # @param [Symbol] field
        #   the field to test for
        #
        # @return [true] if the instance contains the given +field+
        # @return [false] otherwise
        #
        # @api private
        def field?(field)
          entries.values.any? { |name| name.field == field }
        end

        private

        def renamed_entries(aliases)
          aliases.each_with_object(entries.dup) { |(from, to), renamed|
            renamed[@inverted.fetch(from)] = to
          }
        end

      end # class Index

    end # class Aliases
  end # module Relation
end # module DataMapper
