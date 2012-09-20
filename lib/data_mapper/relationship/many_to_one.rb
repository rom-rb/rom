module DataMapper
  class Relationship

    class ManyToOne < self

      def finalize_aliases
        @source_aliases = super.merge(
          target_key => unique_alias(target_key, name)
        )
      end

      private

      # @api private
      def default_source_key
        foreign_key_name
      end

      # @api private
      def default_target_key
        :id
      end

      # @api private
      def relationship_builder
        Builder::ManyToOne
      end
    end # class ManyToOne
  end # class Relationship
end # module DataMapper
