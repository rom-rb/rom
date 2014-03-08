# encoding: utf-8

module ROM
  class Mapper

    # Abstract loader class
    #
    # @private
    class Loader
      include Concord::Public.new(:header, :model, :transformer), Adamantium, AbstractType

      abstract_method :call

      def self.build(header, model)
        new(header, model, header.transformer)
      end

      # @api public
      def identity(tuple)
        header.keys.map { |key| tuple[key.name] }
      end

    end # Loader

  end # Mapper
end # ROM
