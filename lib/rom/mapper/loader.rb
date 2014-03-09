# encoding: utf-8

module ROM
  class Mapper

    # Abstract loader class
    #
    # @private
    class Loader
      include Concord::Public.new(:header, :model, :transformer), Adamantium, AbstractType
      extend Morpher::NodeHelpers

      abstract_method :call

      def self.build(header, model)
        transformer_ast = s(:block, header.transformer_ast, transformer_node(model, header.attribute_names))
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
