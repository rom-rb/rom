module DataMapper
  class Engine
    module Arel

      # Relation node wrapping arel relation
      #
      class Node < Relation::Graph::Node
        include Enumerable

        def self.join_strategy
          Relation::Header::JoinStrategy::InnerJoin
        end

        private_class_method :join_strategy

        # @api public
        def each(&block)
          return to_enum unless block_given?
          relation.each do |row|
            yield(Hash[row.map { |key, value| [ key.to_sym, value ] }])
          end
          self
        end

        # @api public
        def [](name)
          relation[name]
        end

        # @api public
        def restrict(query, &block)
          new(name, relation.restrict(query.to_h, &block), aliases)
        end

        # @api public
        def order(*fields)
          new(name, relation.order(*fields.map { |field| relation[field] }))
        end

        # @api public
        def take(amount)
          new(name, relation.take(amount), aliases)
        end

        # @api public
        def skip(offset)
          new(name, relation.skip(offset), aliases)
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
