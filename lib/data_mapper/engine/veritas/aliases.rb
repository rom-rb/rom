module DataMapper
  class Engine
    module Veritas

      # The aliases to use when joining nodes
      #
      # @abstract
      #
      # @api private
      class Aliases
        include AbstractType, Enumerable
        include Equalizer.new(:entries)

        # A hash containing +original_field+ => +current_field+ pairs
        #
        # @return [Hash]
        #
        # @api private
        attr_reader :entries

        # Initialize a new instance
        #
        # @see Mapper::AttributeSet#aliases
        #
        # @param [#to_hash] entries
        #   a hash returned from (private) {Mapper::AttributeSet#aliased_field_map}
        #
        # @param [#to_hash] aliases
        #   a hash returned from (private) {Mapper::AttributeSet#original_aliases}
        #
        # @return [undefined]
        #
        # @api private
        def initialize(entries, aliases)
          @entries = entries.to_hash
          @aliases = aliases.to_hash
        end

        abstract_method :old_field
        private :old_field

        abstract_method :initial_aliases
        private :initial_aliases

        # Join self with other keeping track of previous aliasing
        #
        # @param [Aliases] other
        #   the other aliases to join with self
        #
        # @param [#to_hash] join_definition
        #   a hash with +left_key+ => +right_key+ mappings used for the join
        #
        # @return [Aliases::Binary]
        #   the aliases to use for the left side of the join
        #
        # @api private
        def join(other, join_definition)
          left    = @entries.dup
          right   = other.entries
          aliases = initial_aliases

          join_definition.to_hash.each do |left_key, right_key|
            old = old_field(left, left_key)

            add_alias(aliases, old, right_key)
            update_dependent_keys(left, old, right_key)

            left[left_key] = right_key
          end

          Binary.new(left.merge(right), aliases)
        end

        # Iterate over the aliases for the left side of a join
        #
        # @param [Proc] &block
        #   the block to pass
        #
        # @yield [old_name, new_name]
        #
        # @yieldparam [#to_sym] old_name
        #   a field's old name
        #
        # @yieldparam [#to_sym] new_name
        #   a field's new name
        #
        # @return [self]
        #
        # @api private
        def each(&block)
          return to_enum unless block_given?
          @aliases.each(&block)
          self
        end

        def alias(name)
          @entries[name.to_sym]
        end

        def to_hash
          @aliases.dup
        end

        private

        # Alias old left key to right key if the joined relation
        # header still includes the old left key
        #
        # Mutates passed in aliases
        #
        # @api private
        def add_alias(aliases, old, right_key)
          if @header.include?(old)
            aliases[old] = right_key
          end
        end

        # Update all original left keys that are to be joined with right
        # key. This makes sure that all previous attribute names that
        # have been collapsed during joins, still point to the correct
        # name. This is necessary to be able to specify source_key and
        # target_key options that point to original attribute names that
        # have since been renamed during previous join operations.
        #
        # Mutates passed in left entries
        #
        # @api private
        def update_dependent_keys(left, old, right_key)
          left.each do |original, current|
            left[original] = right_key if left[original] == old
          end
        end

      end # class Aliases

    end # module Veritas
  end # class RelationRegistry
end # module DataMapper
