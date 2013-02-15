module Veritas
  module Adapter

    class DataObjects

      def gateway(relation)
        Veritas::Relation::Gateway.new(self, relation)
      end
    end # class DataObjects
  end # module Adapter
end # module Veritas
