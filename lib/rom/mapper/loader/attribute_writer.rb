# encoding: utf-8

module ROM
  class Mapper
    class Loader

      # Special type of Allocator loader which uses attribute writers
      #
      # @private
      class AttributeWriter < Allocator

        # @api private
        def self.transformer_node_name
          :load_attribute_accessors
        end

      end # AttributeWriter

    end # Loader
  end # Mapper
end # ROM
