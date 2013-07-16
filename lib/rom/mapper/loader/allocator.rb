module ROM
  class Mapper
    class Loader

      # @private
      class Allocator < self

        # @api private
        def call(tuple)
          allocate { |attribute, object|
            object.instance_variable_set(
              "@#{attribute.name}", tuple[attribute.tuple_key]
            )
          }
        end

        private

        # @api private
        def allocate(&block)
          header.each_with_object(model.allocate, &block)
        end

      end # Allocator

    end # Loader
  end # Mapper
end # ROM
