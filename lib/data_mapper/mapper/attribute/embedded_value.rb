module DataMapper
  class Mapper
    class Attribute

      class EmbeddedValue < Attribute
        MissingTypeOptionError = Class.new(StandardError)

        attr_reader :mapper

        def initialize(name, options = {})
          super
          @type    = options.fetch(:type) { raise(MissingTypeOptionError) }
          @aliases = options.fetch(:aliases, {})
        end

        # @api public
        def finalize
          mapper = DataMapper[type]
          mapper = mapper.remap(@aliases) if @aliases.any?

          @mapper = mapper
        end

        # @api public
        def inspect
          "<##{self.class.name} @name=#{name} @mapper=#{mapper}>"
        end

        # @api public
        def load(tuple)
          begin
            mapper.load(tuple)
          rescue
            # FIXME: remove this when tuple#include? is implemented
            nil
          end
        end

        # @api private
        def primitive?
          false
        end
      end # class EmbeddedValue
    end # class Attribute
  end # class Mapper
end # module DataMapper
