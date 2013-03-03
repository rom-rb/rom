module DataMapper
  class Relationship

    # Represent a M:1 relationship
    class ManyToOne < self

      private

      DEFAULT_TARGET_KEY = [ :id ].freeze

      # @see Options#default_source_key
      #
      def default_source_key
        [ self.class.foreign_key_name(name.to_s) ].freeze
      end

      # @see Options#default_target_key
      #
      def default_target_key
        DEFAULT_TARGET_KEY
      end
    end # class ManyToOne
  end # class Relationship
end # module DataMapper
