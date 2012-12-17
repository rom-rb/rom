module DataMapper
  class Engine
    module Arel

      # Relation node wrapping arel relation
      #
      class Node < Relation::Graph::Node
        include Enumerable

        def self.aliasing_strategy
          Relation::Aliases::Strategy::InnerJoin
        end

        private_class_method :aliasing_strategy

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

        # @api public
        def restrict(query, &block)
          new(name, gateway.restrict(query.to_h, &block), aliases)
        end

        # @api public
        def take(amount)
          new(name, gateway.take(amount), aliases)
        end

        # @api public
        def skip(offset)
          new(name, gateway.skip(offset), aliases)
        end

        # @api public
        def sort_by(&block)
          raise NotImplementedError
        end

        # @api public
        def rename(new_aliases)
          raise NotImplementedError
        end

        # @api public
        def header
          raise NotImplementedError
        end

      end # class Node

    end # module Arel
  end # class Engine
end # module DataMapper
