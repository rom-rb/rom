module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship
      attr_reader :name

      def initialize(name, options)
        @name         = name
        @model_name   = options.fetch(:model_name) { Inflector.classify(name) }
        @options      = options
        @mapper_class = options[:mapper]
        @operation    = options[:operation]
      end

      # @api public
      def finalize
        @child_relation = DataMapper[Inflector.constantize(@model_name)].relation
        self
      end

      # @apu public
      def call(parent_relation)
        @mapper_class.new(@operation.call(parent_relation, @child_relation))
      end

      # @api public
      def field_name(name)
        @mapper.attributes.field_name(name)
      end

    end # class Relationship
  end # class Mapper
end # module DataMapper
