module DataMapper
  class Engine
    module Arel

      # Relation node wrapping arel relation
      #
      class Node < Relation::Graph::Node
        include Enumerable

        alias_method :gateway, :relation

        # @api public
        def each(&block)
          return to_enum unless block_given?
          gateway.each do |row|
            yield(Hash[row.map { |key, value| [ key.to_sym, value ] }])
          end
          self
        end

        # @api public
        def [](name)
          gateway.relation[name]
        end

        # @api private
        def rename(new_aliases)
          raise NotImplementedError
        end

        # @api private
        def header
          raise NotImplementedError
        end

        # @api private
        def restrict(*args, &block)
          raise NotImplementedError
        end

        # @api private
        def sort_by(&block)
          raise NotImplementedError
        end

      end # class Node
    end # module Arel
  end # class Engine
end # module DataMapper
