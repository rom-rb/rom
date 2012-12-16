module DataMapper
  class Engine
    module Arel

      # Relation node wrapping arel relation
      #
      class Node < Relation::Graph::Node
        include Enumerable

        def self.aliasing_strategy
          Relation::Graph::Node::Aliases::Strategy::InnerJoin
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

        # @api private
        def restrict(query, &block)
          self.class.new(name, gateway.restrict(query.to_h, &block), aliases)
        end

        # @api private
        def sort_by(&block)
          raise NotImplementedError
        end

        # @api private
        def rename(new_aliases)
          raise NotImplementedError
        end

        # @api private
        def header
          raise NotImplementedError
        end

      end # class Node
    end # module Arel
  end # class Engine
end # module DataMapper
