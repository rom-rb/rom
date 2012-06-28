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

    end # class Relationship
  end # class Mapper
end # module DataMapper
