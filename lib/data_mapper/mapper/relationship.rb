module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship
      attr_reader :name

      def initialize(name, options)
        @name         = name
        @options      = options
        @source       = options[:source]
        @mapper_class = options[:mapper]
        @operation    = options[:operation]
      end

      # @api public
      def finalize
        self
      end

      # @api public
      def call
        @mapper_class.new(relation)
      end

      # @api public
      def relation
        parent_mapper.instance_exec(child_mapper, &@operation).relation.optimize
      end

      # @api public
      def child_mapper
        @child_mapper ||= if @source
                            @source.child_mapper
                          else
                            DataMapper[@mapper_class.attributes[name].type]
                          end
      end

      # @api public
      def parent_mapper
        @parent_mapper ||= if @source
                            @source.call
                          else
                            DataMapper[@mapper_class.model]
                          end
      end

      # @api public
      def inherit(name, operation)
        self.class.new(name, @options.merge(:source => self, :operation => operation))
      end

    end # class Relationship
  end # class Mapper
end # module DataMapper
