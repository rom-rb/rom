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
          @header   = @entries.values.to_set
          @strategy = strategy.new(self)

          @relation_names = relation_names(self)
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
        def join(index, join_definition, relation_aliases)
          assert_valid_relation_aliases(index, relation_aliases)
          @strategy.join(index, join_definition, relation_aliases)
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
            original_attributes(from).each do |original, current|
              renamed[original] = Attribute.build(to, current.prefix)
            end
          }
        end

        def original_attributes(field)
          Hash[entries.select { |original, current| current.field == field }]
        end

        def assert_valid_relation_aliases(index, aliases)
          unless aliases.keys.to_set == common_relation_names(index)
            raise InvalidRelationAliasError
          end
        end

        def common_relation_names(index)
          @relation_names & relation_names(index)
        end

        def relation_names(index)
          index.entries.keys.map(&:prefix).to_set
        end
      end # class Index

    end # class Aliases
  end # module Relation
end # module DataMapper
