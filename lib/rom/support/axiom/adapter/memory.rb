require 'axiom-memory-adapter'
require 'rom/support/axiom/adapter'

module Axiom
  module Adapter

    # A axiom in memory adapter
    #
    # This is basically a "null adapter"
    # as it doesn't make use of it's uri
    # and only passes through the given
    # +relation+ in {#gateway}
    #
    class Memory
      extend Adapter

      include Equalizer.new(:schema)

      uri_scheme :memory

    end # class Memory
  end # module Adapter
end # module Axiom
