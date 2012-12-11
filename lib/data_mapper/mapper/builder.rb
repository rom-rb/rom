module DataMapper
  class Mapper

    # Mapper class builder
    #
    class Builder

      # Builds a mapper class for the given model and repository
      #
      # @example
      #   class User; end
      #
      #   mapper = DataMapper::Mapper::Builder.create(User, :default)
      #
      #   mapper.model         #=> User
      #   mapper.repository    #=> :default
      #   mapper.relation_name #=> :users
      #
      # @param [Model, ::Class(.name, .attribute_set)] model
      #   the model used by the generated mapper
      #
      # @param [Symbol] repository
      #   the repository name to use for the generated mapper
      #
      # @param [Proc, nil] block
      #   a block to be class_eval'ed in the context of the generated mapper
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def self.create(model, repository, &block)
        mapper = define_for(model)

        mapper.relation_name(Inflector.tableize(model.name).to_sym)
        mapper.repository(repository)

        copy_attributes(mapper, model.attribute_set) if model.respond_to?(:attribute_set)

        mapper.instance_eval(&block) if block_given?

        mapper
      end

      # Creates a "bare-bone" mapper class for the given model
      #
      # @example
      #
      #   class User; end
      #
      #   mapper = DataMapper::Mapper::Builder.define_for(Model)
      #
      #   mapper.model #=> User
      #   mapper.name  #=> UserMapper
      #
      # @param [::Class] model
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def self.define_for(model, parent = Relation::Mapper, name = nil)
        name  ||= name_for(model)

        klass = Class.new(parent)
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
      # @param [Mapper] mapper
      # @param [AttributeSet] attributes
      #
      # @return [Mapper] mapper
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

    end # class Builder

  end # class Mapper
end # module DataMapper
