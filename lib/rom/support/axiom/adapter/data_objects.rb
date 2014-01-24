# encoding: utf-8

require 'axiom-do-adapter'

module Axiom
  module Adapter

    # Reopenend to add functionality that should eventually
    # be puhsed down to Adapter::DataObjects proper, or whatever
    # will be the base class.
    #
    class DataObjects
      extend Adapter

      include Equalizer.new(:uri)

      # The URI this adapter uses for establishing a connection
      #
      # @return [Addressable::URI]
      #
      # @api private
      attr_reader :uri

      # Wrap the given +relation+ with a gateway
      #
      # @param [Axiom::Relation] relation
      #   the relation to wrap with a gateway
      #
      # @return [Axiom::Relation::Gateway]
      #
      # @api private
      def gateway(relation)
        Axiom::Relation::Gateway.new(self, relation)
      end

    end # DataObjects
  end # Adapter
end # Axiom
