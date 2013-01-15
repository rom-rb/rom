module DataMapper
  module Relation
    class Aliases

      class AttributeIndex

        # Build a new {AttributeIndex} instance
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
        # @return [AttributeIndex]
        #
        # @api private
        def self.build(relation_name, attribute_set, strategy_class)
          new(initial_entries(relation_name, attribute_set), strategy_class)
        end

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
        def self.initial_entries(relation_name, attribute_set)
          attribute_set.primitives.each_with_object({}) { |attribute, entries|
            entry = Attribute.build(attribute.field, relation_name)
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
        # @param [*args] args
        #   the arguments accepted by {Strategy#join}
        #
        # @return [AttributeIndex]
        #
        # @api private
        def join(*args)
          strategy.join(*args)
        end

        # Rename attributes indexed by this instance
        #
        # @param [Hash<Symbol, Symbol>] aliases
        #   the aliases to use for renaming
        #
        # @return [AttributeIndex]
        #
        # @api private
        def rename(aliases)
          new(renamed_entries(aliases))
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
            other_name = other.fetch(key).name
            if name.field != other_name
              aliases[name.field] = other_name
            end
          }
        end

        # Tests wether this instance contains the given +field+
        #
        # @param [Symbol] name
        #   the field name to test for
        #
        # @return [true] if the instance contains the given +field+
        # @return [false] otherwise
        #
        # @api private
        def field?(name)
          entries.values.any?(&filter_field(name))
        end

        # The attribute initially named by +name+
        #
        # @param [Symbol] name
        #   the attribute's initial name
        #
        # @return [Attribute]
        #
        # @raise [KeyError]
        #   if no matching attribute exists
        #
        # @api private
        def field(name)
          fetch(entries.keys.detect(&filter_field(name)))
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

        def renamed_entries(aliases)
          aliases.each_with_object(entries.dup) { |(from, to), renamed|
            with_initial_attributes(from) do |initial|
              renamed[initial] = new_attribute(to, initial.prefix)
            end
          }
        end

        def renamed_relations(aliases)
          aliases.each_with_object(entries.dup) { |(from, to), renamed|
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

        FILTER_INITIAL_ATTRIBUTES = proc { |name, current| name == current.field  }
        FILTER_RELATION_SIBLINGS  = proc { |name, current| name == current.prefix }

        def filter_field(name)
          proc { |attribute| attribute.field == name }
        end

        def strategy
          @strategy_class.new(self)
        end

        def new_attribute(field, relation_name)
          Attribute.build(field, relation_name)
        end

        def new(index)
          self.class.new(index, @strategy_class)
        end

      end # class AttributeIndex

    end # class Aliases
  end # module Relation
end # module DataMapper
