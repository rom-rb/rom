module DataMapper
  class Repository

    # A persistent repository backed by base relations accessible via an adapter
    #
    # @api private
    class Persistent < self

      # Initialize a new instance
      #
      # @param [#to_sym] name
      #   the repository's name
      #
      # @param [Veritas::Adapter] adapter
      #   the adapter to access relations
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, adapter)
        super(name)
        @adapter = adapter
      end

      private

      # Build veritas gateway relation
      #
      # @param [Symbol] name
      #   the relatio name
      #
      # @param [Veritas::Relation::Header] header
      #
      # @return [Veritas::Adapter::Gateway]
      #
      # @api private
      #
      def build(name, header)
        @adapter.gateway(Veritas::Relation::Base.new(name, header))
      end
    end # class Persistent
  end # class Repository
end # module DataMapper
