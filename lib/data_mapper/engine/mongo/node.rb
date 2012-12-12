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
          gateway.each(&block)
          self
        end

      end # class Node

    end # module Mongo
  end # class Engine
end # module DataMapper
