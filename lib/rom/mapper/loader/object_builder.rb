# encoding: utf-8

module ROM
  class Mapper
    class Loader

      # Loader class that calls initialize
      #
      # @private
      class ObjectBuilder < self

        # @api private
        def self.transformer_node(model, _)
          s(:load_attributes_hash, model)
        end

      end # ObjectBuilder

    end # Loader
  end # Mapper
end # ROM
