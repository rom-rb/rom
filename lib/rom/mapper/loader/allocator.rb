# encoding: utf-8

module ROM
  class Mapper
    class Loader

      # Loader class which doesn't call initialize
      #
      # @private
      class Allocator < self

        # @api private
        def call(tuple)
          transformer.call(tuple).each_with_object(model.allocate) { |(key, value), object|
            object.instance_variable_set("@#{key}", value)
          }
        end

        private

        # @api private
        def allocate(&block)
          header.attribute_names.each_with_object(model.allocate, &block)
        end

      end # Allocator

    end # Loader
  end # Mapper
end # ROM
