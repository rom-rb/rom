module ROM
  class Mapper

    # @public
    class Loader
      include Concord.new(:header, :model), Adamantium, AbstractType

      abstract_method :call

      # @api public
      def identity(tuple)
        header.keys.map { |key| tuple[key.name] }
      end

    end # Loader

  end # Mapper
end # ROM
