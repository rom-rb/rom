require 'veritas-do-adapter'

module Veritas
  module Adapter

    class DataObjects

      extend Adapter

      include Equalizer.new(:uri)

      attr_reader :uri

      # Wrap the given +relation+ with a gateway
      #
      # @param [Veritas::Relation] relation
      #   the relation to wrap with a gateway
      #
      # @return [Veritas::Relation::Gateway]
      #
      # @api private
      def gateway(relation)
        Veritas::Relation::Gateway.new(self, relation)
      end

    end # class DataObjects
  end # module Adapter
end # module Veritas
