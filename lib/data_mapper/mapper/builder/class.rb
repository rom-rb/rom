module DataMapper
  class Mapper
    class Builder

      class Class

        # @api public
        def self.create(model, repository, &block)
          mapper = define_for(model)

          mapper.model(model)
          mapper.relation_name(Inflector.tableize(model.name))
          mapper.repository(repository)

          copy_attributes(mapper, model.attribute_set)

          mapper.instance_eval(&block) if block_given?

          mapper
        end

        # @api public
        def self.define_for(model)
          ::Class.new(Mapper::Relation::Base) do
            def self.name
              "#{model.name}Mapper"
            end

            # TODO: add specs
            def self.inspect
              "<##{name}:#{object_id}>"
            end
          end
        end

        # @api public
        def self.copy_attributes(mapper, attributes)
          attributes.each do |attribute|
            if attribute.options[:member_type]
              mapper.map attribute.name, attribute.options[:member_type], :collection => true
            else
              mapper.map attribute.name, attribute.options[:primitive]
            end
          end

          mapper
        end

      end # class Class

    end # class Builder
  end # class Mapper
end # module DataMapper
