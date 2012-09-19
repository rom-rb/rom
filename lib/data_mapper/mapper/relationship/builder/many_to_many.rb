module DataMapper
  class Mapper
    class Relationship
      class Builder

        class ManyToMany < OneToMany

          attr_reader :via

          def initialize(source_mapper, options)
            super
            @via = @source_mapper.relationships[options[:through]]
          end

          def operation
            lambda do |targets, relationship|
              via           = relationship.via
              join_relation = relationship.join_relation
              target_model  = relationship.options[:target_model]

              source_renamings = relationship.options[:renamings].merge(
                via.source_key => via.target_key
              )

              via_key    = [DataMapper::Inflector.foreign_key(target_model.name).to_sym]
              target_key = targets.attributes.key.map(&:name)

              join_renamings = Hash[via_key.zip(target_key)]
              target_key.each do |attribute_name|
                join_renamings[attribute_name] = unique_alias(relationship.name, attribute_name)
              end

              rename(source_renamings).
                join(join_relation.rename(join_renamings)).
                join(targets)
            end
          end

          def fields
            @renamings.merge(via.source_key => via.target_key)
          end
        end # class ManyToMany
      end # class Builder
    end # class Relationship
  end # class Mapper
end # module DataMapper
