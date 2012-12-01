module DataMapper
  class Engine
    module Veritas
      class Aliases

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
        # @api private
        class Binary < self

          def initialize(entries, aliases)
            super
            @header = entries.values.to_set
          end

          private

          def old_field(left_entries, left_key)
            left_entries.fetch(left_key)
          end

          def initial_aliases
            {}
          end

        end # class Binary

      end # class Aliases
    end # module Veritas
  end # class RelationRegistry
end # module DataMapper
