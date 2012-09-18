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

      def initialize(name, options)
        @name         = name
        @options      = default_options.merge(options)
        @source       = @options[:source]
        @mapper_class = @options[:mapper]
        @operation    = @options[:operation]

        @source_key   = @options[:source_key]
        @target_key   = @options[:target_key]

        @source_model =
          if @mapper_class
            @mapper_class.model
          else
            @options[:source_model]
          end

        @target_model =
          if @mapper_class
            @mapper_class.attributes[@name].type
          else
            @options[:target_model]
          end
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
        self.class.new(name, @options.merge(:source => self, :operation => operation))
      end

    private

      # @api private
      def finalize_mapper_class
        unless @mapper_class
          builder       = relationship_builder.new(name, @parent_mapper, @options)
          @mapper_class = builder.mapper_class
          @operation    = builder.operation unless @operation
        end
      end

      # @api private
      def finalize_relation
        @relation = @parent_mapper.instance_exec(@child_mapper, self, &@operation).relation.optimize
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

      def default_options
        {
          :source_key => default_source_key,
          :target_key => default_target_key
        }
      end

      def foreign_key_name
        "#{@name}_id".to_sym
      end

      def default_source_key
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      def default_target_key
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      def relationship_builder
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end
    end # class Relationship
  end # class Mapper
end # module DataMapper
