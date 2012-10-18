module DataMapper
  class Mapper
    class Relation

      class Base < self

        # @api private
        def self.from(other)
          klass = super
          klass.relation_name(other.relation_name)
          klass
        end

        # Set or return the name of this mapper's default relation
        #
        # @api public
        def self.relation_name(name = Undefined)
          if name.equal?(Undefined)
            @relation_name
          else
            @relation_name = name
          end
        end

        # @api public
        def self.relation
          @relation ||= engine.base_relation(relation_name, attributes.header)
        end

        # @api public
        def self.key(*names)
          names.each do |name|
            attributes << attributes[name].clone(:key => true)
          end
        end

        # @api private
        def self.engine
          @engine ||= DataMapper.engines[repository]
        end

        # @api private
        def self.aliases
          @aliases ||= AliasSet.new(Inflector.singularize(relation_name), attributes)
        end

        # @api private
        def self.finalize
          Mapper.mapper_registry << new(Mapper.relation_registry.node_for(gateway_relation))
        end

      end # class Base
    end # class Relation
  end # class Mapper
end # module DataMapper
