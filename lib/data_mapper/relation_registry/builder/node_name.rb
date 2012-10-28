module DataMapper
  class RelationRegistry
    class Builder

      # Determines name for relation nodes based on a relationship
      #
      class NodeName
        SEPARATOR = '_X_'.freeze

        attr_reader :left
        attr_reader :right
        attr_reader :relationship_name

        # @api private
        # TODO: add specs
        def initialize(*args)
          @left, @right = args[0..1]
          @relationship_name = args.last if args.size == 3

          unless @left && @right
            raise ArgumentError, "+left+ and +right+ must be defined"
          end
        end

        # @api private
        # TODO: add specs
        def each(&block)
          to_ary.each(&block)
        end

        # @api private
        def to_str
          to_ary.join(SEPARATOR)
        end

        # @api private
        def to_sym
          to_str.to_sym
        end

        # @api private
        def to_ary
          [ left.to_sym, right.to_sym ]
        end

        # @api private
        def to_connector_name
          left_name = left.respond_to?(:to_connector_name) ? left.to_connector_name : left.to_sym
          [ left_name, relationship_name ].join(SEPARATOR).to_sym
        end

      end # class NodeName

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
