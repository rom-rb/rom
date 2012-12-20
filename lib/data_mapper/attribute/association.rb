module DataMapper
  class Attribute

    class Association < EmbeddedValue

      # Load this attribute's value from a tuple
      #
      # @param [(#each, #[])] tuple
      #   the tuple to load
      #
      # @return [Object]
      #
      # @api private
      def load(tuple)
        mapper.load(tuple)
      end

    end # class Association

  end # class Attribute

end # module DataMapper
