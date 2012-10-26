module DataMapper
  class RelationRegistry
    class Builder

      # Determines name for relation nodes based on a relationship
      #
      class NodeName
        SEPARATOR = '_X_'.freeze

        attr_reader :left
        attr_reader :right

        # @api private
        def initialize(*args)
          if args.size == 2
            @left, @right = args.map(&:to_sym)
          else
            @left, @right = args.first.split(SEPARATOR).map(&:to_sym)
          end
        end

        # @api private
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
          [ left, right ]
        end

        # @api private
        def left_of(name)
          (to_ary - [ name ]).join(SEPARATOR).to_sym
        end

      end # class NodeName

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
