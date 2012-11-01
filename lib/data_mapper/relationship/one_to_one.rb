module DataMapper
  class Relationship

    class OneToOne < self

      # @see Options#default_source_key
      #
      def default_source_key
        :id
      end

      # @see Options#default_target_key
      #
      def default_target_key
        self.class.foreign_key_name(source_model.name)
      end
    end # class OneToOne
  end # class Relationship
end # module DataMapper
