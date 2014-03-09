# encoding: utf-8

module ROM
  class Mapper
    class Loader

      # Loader class which doesn't call initialize
      #
      # @private
      class Allocator < self

        # @api private
        def self.transformer_node(model, attributes)
          s(
            transformer_node_name,
            Morpher::Evaluator::Transformer::Domain::Param.new(model, attributes)
          )
        end

        # @api private
        def self.transformer_node_name
          :load_instance_variables
        end

      end # Allocator

    end # Loader
  end # Mapper
end # ROM
