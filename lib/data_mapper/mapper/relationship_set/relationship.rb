module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship
      attr_reader :name

      def initialize(name, options)
        @name     = name
        @mapper   = options.fetch(:mapper)
        @relation = @mapper.relation
      end

      class OneToOne < Relationship

        # @api private
        def join(left)
          @relation.join(left)
        end

        # @api private
        def field
          @mapper.class.relation_name
        end

        # @api private
        def load(attributes)
          @mapper.load(attributes)
        end

      end

    end # class Relationship
  end # class Mapper
end # module DataMapper
