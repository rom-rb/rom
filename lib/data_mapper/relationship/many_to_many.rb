module DataMapper
  class Relationship

    class ManyToMany < OneToMany

      # @see Options#default_target_key
      #
      # @api private
      def default_source_key
        :id
      end

      # @see Options#default_target_key
      #
      # @api private
      def default_target_key
        self.class.foreign_key_name(target_model.name)
      end
    end # class ManyToMany
  end # class Relationship
end # module DataMapper
