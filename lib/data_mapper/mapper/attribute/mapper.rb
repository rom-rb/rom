module DataMapper
  class Mapper
    class Attribute

      class Mapper < Attribute
        MissingTypeOptionError = Class.new(StandardError)

        def initialize(name, options = {})
          super
          @type = options.fetch(:type) { raise(MissingTypeOptionError) }
        end

        # @api public
        def finalize
          @mapper = DataMapper[type]
        end

        # @api public
        def load(tuple)
          @mapper.load(tuple)
        end

        # @api private
        def primitive?
          false
        end

      end # class Mapper

    end # class Attribute
  end # class Mapper
end # module DataMapper
