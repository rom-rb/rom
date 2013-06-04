module ROM
  class Relation
    class Header

      # Keeps track of attributes in {Relation::Header}
      class AttributeIndex

        # Build a new {AttributeIndex} instance
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
        # @return [AttributeIndex]
        #
        # @api private
        def self.build(relation_name, attribute_names, strategy_class)
          new(initial_entries(relation_name, attribute_names), strategy_class)
        end

        # Return index entries as required by {#initialize}
        #
        # @param [#to_sym] relation_name
        #   the name of the relation
        #
        # @param [Enumerable<Symbol>] attribute_names
        #   the set of attribute names to build the index for
        #
        # @return [Hash<Attribute, Attribute>]
        #
        # @api private
        def self.initial_entries(relation_name, attribute_names)
          attribute_names.each_with_object({}) { |attribute_name, entries|
            entry = Attribute.build(attribute_name, relation_name)
            entries[entry] = entry
          }
        end

        private_class_method :initial_entries

        include Adamantium, Equalizer.new(:entries)

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
        # @param [Class] strategy_class
        #   the strategy class to instantiate for {#join}
        #
        # @return [undefined]
        #
        # @api private
        def initialize(entries, strategy_class)
          @entries        = entries
          @header         = @entries.values.to_set
          @strategy_class = strategy_class
        end

        # Join this instance with another one
        #
        # @see Strategy#join
        #
        # @param [AttributeIndex] other
        #   the attribute index to join with self
        #
        # @param [#to_hash] join_definition
        #   the attributes used to perform the join
        #
        # @return [AttributeIndex]
        #
        # @api private
        def join(other, join_definition)
          strategy(join_definition).join(other)
        end

        # Rename attributes indexed by this instance
        #
        # @param [Hash<Symbol, Symbol>] aliases
        #   the aliases to use for renaming
        #
        # @return [AttributeIndex]
        #
        # @api private
        def rename_attributes(aliases)
          new(renamed_attributes(aliases))
        end

        # Rename relations indexed by this instance
        #
        # @param [Hash<Symbol, Symbol>] aliases
        #   the aliases to use for renaming
        #
        # @return [AttributeIndex]
        #
        # @api private
        def rename_relations(aliases)
          new(renamed_relations(aliases))
        end

        # The aliases needed to mimic +other+
        #
        # @param [AttributeIndex] other
        #   the other index to calculate aliases for
        #
        # @return [Hash<Symbol, Symbol>
        #
        # @api private
        def aliases(other)
          entries.each_with_object({}) { |(key, name), aliases|
            field      = name.field
            other_name = other.fetch(key).name
            if field != other_name
              aliases[field] = other_name
            end
          }
        end

        # Tests wether the given +current_name+ is present
        #
        # @param [Symbol] current_name
        #   the current name to look for
        #
        # @return [true] if +current_name+ is present
        # @return [false] otherwise
        #
        # @api private
        def attribute?(current_name)
          entries.values.any?(&filter_field(current_name))
        end

        # The attribute initially named by +initial_name+
        #
        # @param [Symbol] initial_name
        #   the attribute's initial name
        #
        # @return [Attribute]
        #
        # @raise [KeyError]
        #   if no matching attribute exists
        #
        # @api private
        def attribute(initial_name)
          fetch(entries.keys.detect(&filter_field(initial_name)))
        end

        protected

        # Return the current {Attribute} for the given +key+
        #
        # @param [Attribute] key
        #   the original attribute
        #
        # @return [Attribute]
        #   the current {Attribute} if the given +key+ was found
        #
        # @raise [KeyError]
        #   if +key+ isn't indexed by this instance
        #
        # @api private
        def fetch(key)
          entries.fetch(key)
        end

        private

        def renamed_attributes(aliases)
          with_new_entries(aliases) { |from, to, renamed|
            with_initial_attributes(from) do |initial, *|
              renamed[initial] = new_attribute(to, initial.prefix)
            end
          }
        end

        def renamed_relations(aliases)
          with_new_entries(aliases) { |from, to, renamed|
            with_relation_siblings(from) do |initial, current|
              renamed_initial = new_attribute(initial.field, to)
              renamed_current = new_attribute(current.field, to)
              renamed[renamed_initial] = renamed_current
              renamed.delete(initial)
            end
          }
        end

        def with_initial_attributes(current_field, &block)
          with_entries(current_field, FILTER_INITIAL_ATTRIBUTES, &block)
        end

        def with_relation_siblings(relation_name, &block)
          with_entries(relation_name, FILTER_RELATION_SIBLINGS, &block)
        end

        def with_entries(name, filter)
          entries.each do |initial, current|
            yield(initial, current) if filter.call(name, current)
          end
        end

        def with_new_entries(aliases)
          aliases.each_with_object(entries.dup) do |(from, to), renamed|
            yield(from, to, renamed)
          end
        end

        FILTER_INITIAL_ATTRIBUTES = proc { |name, current| name == current.field  }
        FILTER_RELATION_SIBLINGS  = proc { |name, current| name == current.prefix }

        def filter_field(name)
          proc { |attribute| attribute.field == name }
        end

        def strategy(join_definition)
          @strategy_class.new(self, join_definition)
        end

        def new_attribute(field, relation_name)
          Attribute.build(field, relation_name)
        end

        def new(index)
          self.class.new(index, @strategy_class)
        end

      end # class AttributeIndex

    end # class Header
  end # class Relation
end # module ROM
