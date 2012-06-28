module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship
      attr_reader :name

      def initialize(name, options)
        @name       = name
        @model_name = options.fetch(:model_name) { Inflector.classify(@name.to_s) }
        @mapper     = options[:mapper]
      end

      def finalize
        @model    = Inflector.constantize(@model_name)
        @mapper ||= DataMapper[@model]
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
