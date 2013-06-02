module Rom
  class Relationship

    # Represent a 1:N relationship
    class OneToMany < self

      include CollectionBehavior

      # @see Options#default_target_key
      #
      def default_target_key
        [ self.class.foreign_key_name(source_model.name) ].freeze
      end
    end # class OneToMany
  end # class Relationship
end # module Rom
