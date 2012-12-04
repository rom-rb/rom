module DataMapper
  module Relation
    class Graph
      class Node
        class Aliases

          # Represents base relation aliases
          #
          # @example
          #
          #   songs = Aliases::Unary.new({
          #     :songs_id    => :songs_id,
          #     :songs_title => :songs_title,
          #   }, {
          #     :id    => :songs_id,
          #     :title => :songs_title,
          #   })
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
          # @api private
          class Unary < self

            def initialize(entries, aliases)
              super
              @header   = aliases.keys.to_set
              @inverted = aliases.invert
            end

            private

            def old_field(left_entries, left_key)
              # FIXME: we can't use fetch here because it fails on RBX 1.9
              @inverted[left_key] || raise(ArgumentError, "+left_key+ cannot be found")
            end

            def initial_aliases
              @aliases.dup
            end

          end # class Unary

        end # class Aliases
      end # class Node
    end # class Graph
  end # module Relation
end # module DataMapper
