module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship
      attr_reader :name
      attr_reader :relation
      attr_reader :child_mapper
      attr_reader :source_key
      attr_reader :target_key
      attr_reader :options

      def initialize(options)
        @options      = options
        @name         = @options.name
        @source       = @options.source
        @mapper_class = @options.mapper_class
        @operation    = @options.operation
        @source_key   = @options.source_key
        @target_key   = @options.target_key
        @source_model = @options.source_model
        @target_model = @options.target_model
      end

      # @api public
      def finalize
        finalize_parent_mapper
        finalize_child_mapper
        finalize_mapper_class
        finalize_relation
        self
      end

      # @api public
      def call
        @mapper_class.new(relation)
      end

      # @api public
      def inherit(name, operation)
        self.class.new(@options.inherit(name, :source => self, :operation => operation))
      end

    private

      # @api private
      def finalize_mapper_class
        unless @mapper_class
          builder       = relationship_builder.new(@parent_mapper, @options)
          @mapper_class = builder.mapper_class
          @operation    = builder.operation unless @operation
        end
      end

      # @api private
      def finalize_relation
        @relation = @parent_mapper.instance_exec(*operation_context, &@operation).relation.optimize
      end

      # @api private
      def finalize_child_mapper
        @child_mapper = if @source
                          @source.finalize.child_mapper
                        else
                          DataMapper[@target_model]
                        end
      end

      # @api private
      def finalize_parent_mapper
        @parent_mapper = if @source
                           @source.finalize.call
                         else
                           DataMapper[@source_model]
                         end
      end

      # @api private
      def relationship_builder
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      def operation_context
        case @operation.arity
        when 0
          []
        when 1
          [@child_mapper]
        when -1, 2
          [@child_mapper, self]
        else
          # TODO raise a more appropriate/descriptive error?
          raise ArgumentError, "Wrong number of block parameters"
        end
      end
    end # class Relationship
  end # class Mapper
end # module DataMapper
