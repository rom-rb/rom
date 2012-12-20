module DataMapper
  class Attribute

    class EmbeddedCollection < Association

      # Load this attribute's value from a tuple
      #
      # @see EmbeddedValue#load
      #
      # @param [(#each, #[])] tuple
      #   the tuple to load
      #
      # @return [Object]
      #
      # @api private
      def load(tuple)
        tuple[field].map { |member| super(member) }
      end

    end # class EmbeddedCollection

  end # class Attribute

end # module DataMapper
