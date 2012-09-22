module DataMapper
  class Relationship

    class OneToOne < self

      private

      def default_source_key
        :id
      end

      def default_target_key
        foreign_key_name
      end

      # @api private
      def mapper_builder_class
        Mapper::Builder::Relationship::OneToOne
      end
    end # class OneToOne
  end # class Relationship
end # module DataMapper
