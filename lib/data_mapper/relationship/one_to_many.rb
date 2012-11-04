module DataMapper
  class Relationship

    class OneToMany < self

      # Returns if the relationship has collection target
      #
      # @return [Boolean]
      #
      # @api private
      def collection_target?
        true
      end

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
    end # class OneToMany
  end # class Relationship
end # module DataMapper
