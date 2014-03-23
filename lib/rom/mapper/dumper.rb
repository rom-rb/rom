# encoding: utf-8

module ROM
  class Mapper

    # Dumps an object back into a tuple
    #
    # @private
    class Dumper
      include Concord::Public.new(:header, :transformer), Adamantium

      # @api public
      def self.build(header, transformer)
        new(header, transformer)
      end

      # @api private
      def call(object)
        ary = transformer.call(object)

        ary.each_with_object([]) do |(name, value), tuple|
          attribute = header[name]

          if attribute.header
            tuple << value.values_at(*attribute.header.attribute_names)
          else
            tuple << value
          end
        end
      end

      # @api private
      def identity(object)
        header.keys.map { |key| object.send(key.name) }
      end

    end # Dumper

  end # Mapper
end # ROM
