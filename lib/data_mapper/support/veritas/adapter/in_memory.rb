require 'data_mapper/support/veritas/adapter'

module Veritas
  module Adapter

    # A veritas in memory adapter
    #
    # This is basically a "null adapter"
    # as it doesn't make use of it's uri
    # and only passes through the given
    # +relation+ in {#gateway}
    #
    class InMemory

      extend Adapter

      include Equalizer.new(:uri)

      uri_scheme :in_memory

      attr_reader :uri

      def initialize(uri)
        @uri = uri
      end

      def gateway(relation)
        relation
      end

    end # class InMemory
  end # module Adapter
end # module Veritas
