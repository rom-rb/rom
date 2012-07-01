module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship
      attr_reader :name, :relation, :child_mapper

      def initialize(name, options)
        @name         = name
        @options      = options
        @source       = options[:source]
        @mapper_class = options[:mapper]
        @operation    = options[:operation]
      end

      # @api public
      def finalize
        finalize_parent_mapper
        finalize_child_mapper
        finalize_relation
        self
      end

      # @api public
      def call
        @mapper_class.new(relation)
      end

      # @api public
      def inherit(name, operation)
        self.class.new(name, @options.merge(:source => self, :operation => operation))
      end

    private

      # @api private
      def finalize_relation
        @relation = @parent_mapper.instance_exec(@child_mapper, &@operation).relation.optimize
      end

      # @api private
      def finalize_child_mapper
        @child_mapper = if @source
                          @source.finalize.child_mapper
                        else
                          DataMapper[@mapper_class.attributes[name].type]
                        end
      end

      # @api private
      def finalize_parent_mapper
        @parent_mapper = if @source
                           @source.finalize.call
                         else
                           DataMapper[@mapper_class.model]
                         end
      end

    end # class Relationship
  end # class Mapper
end # module DataMapper
