module Rom
  class Relationship

    module CollectionBehavior

      # Returns if the relationship has collection target
      #
      # @return [Boolean]
      #
      # @api private
      def collection_target?
        true
      end
    end # module CollectionBehavior
  end # class Relationship
end # module Rom
