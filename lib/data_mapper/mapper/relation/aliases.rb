module DataMapper
  class Mapper
    class Relation < self

      # Tracks +original_alias+ => +current_alias+ mappings
      #
      # @example Join a series of other field mappings
      #
      #   songs = Aliases::Unary.new({
      #     :songs_id    => :songs_id,
      #     :songs_title => :songs_title,
      #   }, {
      #     :id    => :songs_id,
      #     :title => :songs_title,
      #   })
      #
      #   song_tags = Aliases::Unary.new({
      #     :song_tags_song_id => :song_tags_song_id,
      #     :song_tags_tag_id  => :song_tags_tag_id,
      #   }, {
      #     :song_id => :song_tags_song_id,
      #     :tag_id  => :song_tags_tag_id,
      #   })
      #
      #   tags = Aliases::Unary.new({
      #     :tags_id   => :tags_id,
      #     :tags_name => :tags_name,
      #   }, {
      #     :id   => :tags_id,
      #     :name => :tags_name,
      #   })
      #
      #   infos = Aliases::Unary.new({
      #     :infos_id     => :infos_id,
      #     :infos_tag_id => :infos_tag_id,
      #     :infos_text   => :infos_text,
      #   }, {
      #     :id     => :infos_id,
      #     :tag_id => :infos_tag_id,
      #     :text   => :infos_text,
      #   })
      #
      #   song_comments = Aliases::Unary.new({
      #     :song_comments_song_id    => :song_comments_song_id,
      #     :song_comments_comment_id => :song_comments_comment_id,
      #   }, {
      #     :song_id    => :song_comments_song_id,
      #     :comment_id => :song_comments_comment_id,
      #   })
      #
      #   comments = Aliases::Unary.new({
      #     :comments_id   => :comments_id,
      #     :comments_text => :comments_text,
      #   }, {
      #     :id   => :comments_id,
      #     :text => :comments_text,
      #   })
      #
      #   # -----------------------------------------------------------------
      #
      #   songs.entries == {
      #     :songs_id    => :songs_id,
      #     :songs_title => :songs_title,
      #   }
      #
      #   # aliases == {
      #   #   :id    => :songs_id
      #   #   :title => :songs_title
      #   # }
      #
      #   # header == Set[
      #   #   :id,
      #   #   :title
      #   # ]
      #
      #   # -----------------------------------------------------------------
      #
      #   song_tags.entries == {
      #     :song_tags_song_id => :song_tags_song_id,
      #     :song_tags_tag_id  => :song_tags_tag_id,
      #   }
      #
      #   # aliases == {
      #   #   :song_id => :song_tags_song_id
      #   #   :tag_id  => :song_tags_tag_id
      #   # }
      #
      #   # header == Set[
      #   #   :song_id,
      #   #   :tag_id
      #   # ]
      #
      #   # -----------------------------------------------------------------
      #
      #   joined = songs.join(song_tags, { :songs_id => :song_tags_song_id })
      #
      #   joined.entries == {
      #     :songs_id          => :song_tags_song_id,
      #     :songs_title       => :songs_title,
      #     :song_tags_song_id => :song_tags_song_id,
      #     :song_tags_tag_id  => :song_tags_tag_id,
      #   }
      #
      #   # aliases == {
      #   #   :id    => :song_tags_song_id
      #   #   :title => :songs_title
      #   # }
      #
      #   # header == Set[
      #   #   :song_tags_song_id,
      #   #   :songs_title,
      #   #   :song_tags_tag_id
      #   # ]
      #
      #   # -----------------------------------------------------------------
      #
      #   joined = joined.join(tags, { :song_tags_tag_id => :tags_id })
      #
      #   joined.entries == {
      #     :songs_id          => :song_tags_song_id,
      #     :songs_title       => :songs_title,
      #     :song_tags_song_id => :song_tags_song_id,
      #     :song_tags_tag_id  => :tags_id,
      #     :tags_id           => :tags_id,
      #     :tags_name         => :tags_name,
      #   }
      #
      #   # aliases == {
      #   #   :song_tags_tag_id => :tags_id
      #   # }
      #
      #   # header == Set[
      #   #   :song_tags_song_id,
      #   #   :songs_title,
      #   #   :tags_id,
      #   #   :tags_name
      #   # ]
      #
      #   # -----------------------------------------------------------------
      #
      #   joined = joined.join(infos, { :tags_id => :infos_tag_id })
      #
      #   joined.entries == {
      #     :songs_id          => :song_tags_song_id,
      #     :songs_title       => :songs_title,
      #     :song_tags_song_id => :song_tags_song_id,
      #     :song_tags_tag_id  => :infos_tag_id,
      #     :tags_id           => :infos_tag_id,
      #     :tags_name         => :tags_name,
      #     :infos_id          => :infos_id,
      #     :infos_tag_id      => :infos_tag_id,
      #     :infos_text        => :infos_text,
      #   }
      #
      #   # aliases == {
      #   #   :tags_id => :infos_tag_id
      #   # }
      #
      #   # header == Set[
      #   #   :song_tags_song_id,
      #   #   :songs_title,
      #   #   :tags_name,
      #   #   :infos_id,
      #   #   :infos_tag_id,
      #   #   :infos_text
      #   # ]
      #
      #   # -----------------------------------------------------------------
      #
      #   joined = joined.join(song_comments, { :songs_id => :song_comments_song_id })
      #
      #   joined.entries == {
      #     :songs_id                 => :song_comments_song_id,
      #     :songs_title              => :songs_title,
      #     :song_tags_song_id        => :song_comments_song_id,
      #     :song_tags_tag_id         => :infos_tag_id,
      #     :tags_id                  => :infos_tag_id,
      #     :tags_name                => :tags_name,
      #     :infos_id                 => :infos_id,
      #     :infos_tag_id             => :infos_tag_id,
      #     :infos_text               => :infos_text,
      #     :song_comments_song_id    => :song_comments_song_id,
      #     :song_comments_comment_id => :song_comments_comment_id
      #   }
      #
      #   # aliases == {
      #   #   :song_tags_song_id => :song_comments_song_id
      #   # }
      #
      #   # header == Set[
      #   #   :songs_title,
      #   #   :tags_name,
      #   #   :infos_id,
      #   #   :infos_tag_id,
      #   #   :infos_text,
      #   #   :song_comments_song_id,
      #   #   :song_comments_comment_id
      #   # ]
      #
      #   # -----------------------------------------------------------------
      #
      #   joined = joined.join(comments, { :song_comments_comment_id => :comments_id })
      #
      #   joined.entries == {
      #     :songs_id                 => :song_comments_song_id,
      #     :songs_title              => :songs_title,
      #     :song_tags_song_id        => :song_comments_song_id,
      #     :song_tags_tag_id         => :infos_tag_id,
      #     :tags_id                  => :infos_tag_id,
      #     :tags_name                => :tags_name,
      #     :infos_id                 => :infos_id,
      #     :infos_tag_id             => :infos_tag_id,
      #     :infos_text               => :infos_text,
      #     :song_comments_song_id    => :song_comments_song_id,
      #     :song_comments_comment_id => :comments_id,
      #     :comments_id              => :comments_id,
      #     :comments_text            => :comments_text
      #   }
      #
      #   # aliases == {
      #   #   :song_comments_comment_id => :comments_id
      #   # }
      #
      #   # header == Set[
      #   #   :songs_title,
      #   #   :tags_name,
      #   #   :infos_id,
      #   #   :infos_tag_id,
      #   #   :infos_text,
      #   #   :song_comments_song_id,
      #   #   :comments_id,
      #   #   :comments_text
      #   # ]
      #
      # @abstract
      #
      # @api private
      class Aliases

        class Unary < self

          private

          def initialize(entries, aliases)
            super
            @header   = aliases.keys.to_set
            @inverted = aliases.invert
          end

          def old_field(left_entries, left_key)
            @inverted.fetch(left_key)
          end

          def initial_aliases
            @aliases.dup
          end
        end # class Unary

        class Binary < self

          private

          def initialize(entries, aliases)
            super
            @header = entries.values.to_set
          end

          def old_field(left_entries, left_key)
            left_entries.fetch(left_key)
          end

          def initial_aliases
            {}
          end
        end # class Binary

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
    end # class Relation
  end # class Mapper
end # module DataMapper

# via source/target keys are inferred during Relationship#finalize
# Added support for composite keys in relationship definitions
# Aliasing now happens at the time two nodes are joined (VeritasEdge#node(relationship))
# JoinKeyMap is refactored and available from Relationship#join_definition (set during Relationship#finalize)
# NodeNameSet now works for *all* relationship types (previously only M:N)
# RelationRegistry::Builder is simplified using
# 1) the new NodeNameSet + Relationship#join_definition
# 2) the new VeritasEdge that performs the join without creating a temporary node
# Simplified Finalizer code (due to lack of upfront aliasing)
