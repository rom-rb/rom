module DataMapper
  class Engine
    module Veritas
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
            @inverted.fetch(left_key)
          end

          def initial_aliases
            @aliases.dup
          end

        end # class Unary

      end # class Aliases

    end # module Veritas
  end # class RelationRegistry
end # module DataMapper
