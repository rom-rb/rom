module DataMapper
  class Engine
    module Mongo

      # Relation node wrapping arel relation
      #
      class Node < Relation::Graph::Node
        include Enumerable

        alias_method :gateway, :relation

        # @api public
        def each(&block)
          return to_enum unless block_given?
          gateway.each do |document|
            yield(Hash[document.map { |key, value| [ key.to_sym, value ] }])
          end
          self
        end

      end # class Node

    end # module Mongo
  end # class Engine
end # module DataMapper
