module DataMapper
  class Relationship

    class ManyToMany < OneToMany

      attr_reader :via
      attr_reader :join_relation
      attr_reader :join_aliases

      def finalize_aliases
        through         = options.through
        @via            = @mapper_class.relationships[through]
        @join_relation  = DataMapper.relation_registry[through]
        @source_aliases = options.aliases

        if @via
          @source_aliases = @source_aliases.merge(@via.source_key => @via.target_key)
        end

        via_key    = [DataMapper::Inflector.foreign_key(options.target_model.name).to_sym]
        target_key = @child_mapper.attributes.key_names

        @join_aliases = Hash[via_key.zip(target_key)]
        target_key.each do |attribute_name|
          # FIXME: handle it better when header#include? is available in veritas
          if (@join_relation.header[attribute_name] rescue false)
            @join_aliases[attribute_name] = unique_alias(attribute_name, name)
          end
        end
      end

      private

      # @api private
      def mapper_builder
        Mapper::Builder::Relationship::ManyToMany
      end
    end # class ManyToMany
  end # class Relationship
end # module DataMapper
