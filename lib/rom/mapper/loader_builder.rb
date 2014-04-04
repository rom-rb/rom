# encoding: utf-8

module ROM
  class Mapper

    # Abstract loader class
    #
    # @private
    class LoaderBuilder
      extend Morpher::NodeHelpers

      def self.call(header, model, type)
        param =
          if type == :load_attribute_hash
            s(:param, model)
          else
            s(:param, model, *header.attribute_names)
          end

        Morpher.compile(s(:block, header.to_ast, s(type, param)))
      end

    end # Loader

  end # Mapper
end # ROM
