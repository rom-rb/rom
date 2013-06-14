module ROM
  class Session

    # A class to read objects via the identity map
    class Reader
      include Concord.new(:session, :mapper)

      public :session, :mapper

      # Load object from +tuple+
      #
      # @param [#[]] tuple
      #   the tuple used to load an object
      #
      # @return [Object]
      #   a domain model instance
      #
      # @api private
      def load(tuple)
        session.load(mapper.loader(tuple))
      end

    end
  end
end
