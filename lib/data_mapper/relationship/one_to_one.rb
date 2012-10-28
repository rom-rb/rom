module DataMapper
  class Relationship

    class OneToOne < self

      private

      # TODO: add specs
      def default_source_key
        :id
      end

      # TODO: add specs
      def default_target_key
        foreign_key_name
      end
    end # class OneToOne
  end # class Relationship
end # module DataMapper
