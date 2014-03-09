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
        transformer_ast = header.transformer_ast.append(
          s(:load_instance_variables,
            Morpher::Evaluator::Transformer::Domain::Param.new(model, header.attribute_names)
           )
        )

        new(header, model, Morpher.compile(transformer_ast))
      end

      # @api public
      def identity(tuple)
        header.keys.map { |key| tuple[key.name] }
      end

    end # Loader

  end # Mapper
end # ROM
