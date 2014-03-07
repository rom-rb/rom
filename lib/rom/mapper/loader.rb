# encoding: utf-8

module ROM
  class Mapper

    # Abstract loader class
    #
    # @private
    class Loader
      include Concord::Public.new(:header, :model, :transformer), Adamantium, AbstractType

      abstract_method :call

      # @api public
      def identity(tuple)
        header.keys.map { |key| tuple[key.name] }
      end

    end # Loader

  end # Mapper
end # ROM
