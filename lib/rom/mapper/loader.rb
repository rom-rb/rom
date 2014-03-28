# encoding: utf-8

module ROM
  class Mapper

    # Abstract loader class
    #
    # @private
    class Loader
      extend Morpher::NodeHelpers

      def self.build(header, model, type)
        param =
          if type == :load_attribute_hash
            model
          else
            s(:param, model, *header.attribute_names)
          end

        transformer_node = s(type, param)
        transformer_ast  = s(:block, header.to_ast, transformer_node)

        Morpher.compile(transformer_ast)
      end

    end # Loader

  end # Mapper
end # ROM
