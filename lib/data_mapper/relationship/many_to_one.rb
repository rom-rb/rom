module DataMapper
  class Relationship

    class ManyToOne < self

      # @see Options#default_source_key
      #
      def default_source_key
        self.class.foreign_key_name(source_model.name)
      end

      # @see Options#default_target_key
      #
      def default_target_key
        :id
      end
    end # class ManyToOne
  end # class Relationship
end # module DataMapper
