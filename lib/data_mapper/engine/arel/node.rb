module DataMapper
  class Engine
    module Arel

      # Relation node wrapping arel relation
      #
      class Node < RelationRegistry::Node
        include Enumerable

        alias_method :gateway, :relation

        def self.aliases(relation_name, attribute_set)
          aliased_field_map = attribute_set.aliased_field_map(relation_name)
          original_aliases  = attribute_set.original_aliases(relation_name)

          Aliases::Unary.new(aliased_field_map, original_aliases)
        end

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

      end # class Node
    end # module Arel
  end # class Engine
end # module DataMapper
