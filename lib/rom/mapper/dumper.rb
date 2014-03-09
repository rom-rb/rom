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
        transformer.call(object).values_at(*header.attribute_names)
      end

      # @api private
      def identity(object)
        header.keys.map { |key| object.send(key.name) }
      end

    end # Dumper

  end # Mapper
end # ROM
