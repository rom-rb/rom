module DataMapper
  class Mapper
    class Relation

      class Base < self

        # @api public
        def self.key(*names)
          names.each do |name|
            attributes << attributes[name].clone(:key => true)
          end
        end

        # @api private
        def self.aliases
          @aliases ||= AliasSet.new(Inflector.singularize(relation_name), attributes)
        end

        # @api private
        def self.finalize
          Mapper.mapper_registry << new(relations.node_for(gateway_relation))
        end

      end # class Base

    end # class Relation
  end # class Mapper
end # module DataMapper
