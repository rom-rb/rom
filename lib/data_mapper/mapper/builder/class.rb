module DataMapper
  class Mapper
    class Builder

      # Mapper class builder
      #
      class Class

        # Builds a mapper class for the given model and repository
        #
        # @example
        #   class User; end
        #
        #   mapper = DataMapper::Mapper::Builder::Class.create(User, :default)
        #
        #   mapper.model         #=> User
        #   mapper.repository    #=> :default
        #   mapper.relation_name #=> :users
        #
        # @param [Class] model
        # @param [Symbol] repository name
        # @param [Proc] block that will be evaled in the context of created class
        #
        # @return [Class]
        #
        # @api public
        def self.create(model, repository, &block)
          mapper = define_for(model)

          mapper.relation_name(Inflector.tableize(model.name).to_sym)
          mapper.repository(repository)

          copy_attributes(mapper, model.attribute_set)

          mapper.instance_eval(&block) if block_given?

          mapper
        end

        # Creates a "bare-bone" mapper class for the given model
        #
        # @example
        #
        #   class User; end
        #
        #   mapper = DataMapper::Mapper::Builder::Class.define_for(Model)
        #
        #   mapper.model #=> User
        #   mapper.name  #=> UserMapper
        #
        # @param [Class] model
        #
        # @return [Class]
        #
        # @api public
        def self.define_for(model, parent = Mapper::Relation, name = nil)
          name  ||= name_for(model)

          klass = ::Class.new(parent)
          klass.model(model)

          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.name
              #{name.inspect}
            end

            def self.inspect
              "<#\#{name} @model=\#{model.name}>"
            end
          RUBY

          klass
        end

        # Returns a mapper class name for the given model
        #
        # @return [String] name of the class
        #
        # @api private
        def self.name_for(model)
          "#{model.name}Mapper"
        end

        # Copies all attributes for the given mapper
        #
        # @param [Class] mapper
        # @param [DataMapper::Mapper::AttributeSet] attributes
        #
        # @return [Class] mapper
        #
        # @api private
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
