# encoding: utf-8

module ROM
  class Mapper

    # Abstract loader class
    #
    # @private
    class Loader
      include Concord::Public.new(:header, :model, :transformer), Adamantium
      extend Morpher::NodeHelpers

      def self.build(header, model, node_name)
        param =
          if node_name == :load_attributes_hash
            model
          else
            Morpher::Evaluator::Transformer::Domain::Param.new(
              model, header.attribute_names
            )
          end

        transformer_node = s(node_name, param)
        transformer_ast  = s(:block, header.to_ast, transformer_node)

        new(header, model, Morpher.compile(transformer_ast))
      end

      # @api public
      def call(tuple)
        transformer.call(tuple)
      end

      # @api public
      def identity(tuple)
        header.keys.map { |key| tuple[key.name] }
      end

    end # Loader

  end # Mapper
end # ROM
