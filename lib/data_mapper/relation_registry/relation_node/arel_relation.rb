module DataMapper
  class RelationRegistry
    class RelationNode < Graph::Node

      # Relation node wrapping arel relation
      #
      class ArelRelation < self
        include Enumerable

        alias_method :gateway, :relation

        # @api public
        def each(&block)
          return to_enum unless block_given?
          gateway.each do |row|
            yield(row.symbolize_keys!)
          end
          self
        end

        # @api private
        def join(other, join_definition)
        end

        # @api private
        def base?
          # TODO: push it down to ArelEngine::Gateway
          gateway.relation.kind_of?(Arel::Table)
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

      end # class ArelRelation

    end # class RelationNode
  end # class RelationRegistry
end # module DataMapper
