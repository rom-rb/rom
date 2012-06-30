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
        @parent       = options[:parent]
        @mapper_class = options[:mapper]
        @operation    = options[:operation]
      end

      # @api public
      def finalize
        @base_relation = DataMapper[Inflector.constantize(@model_name)].relation
        self
      end

      # @api public
      def mapper(parent_relation)
        @mapper_class.new(relation(parent_relation).optimize)
      end

      # @apu public
      def relation(parent_relation)
        @operation.call(parent_relation, child_relation(parent_relation))
      end

      # @api public
      def inherit(name, operation)
        self.class.new(name, @options.merge(:parent => self, :operation => operation))
      end

    private

      # @api private
      def child_relation(parent_relation)
        if @parent
          @parent.relation(parent_relation)
        else
          @base_relation
        end
      end

    end # class Relationship
  end # class Mapper
end # module DataMapper
