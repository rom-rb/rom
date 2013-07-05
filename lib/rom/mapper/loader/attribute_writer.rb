module ROM
  class Mapper
    class Loader

      # @private
      class AttributeWriter < Allocator

        # @api private
        def call(tuple)
          allocate { |attribute, object|
            object.public_send("#{attribute.name}=", tuple[attribute.tuple_key])
          }
        end

      end # AttributeWriter

    end # Loader
  end # Mapper
end # ROM
