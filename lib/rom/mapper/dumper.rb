# encoding: utf-8

module ROM
  class Mapper

    # Dumps an object back into a tuple
    #
    # @private
    class Dumper
      include Concord::Public.new(:header, :transformer), Adamantium

      def self.build(header, transformer)
        new(header, transformer)
      end

      # @api private
      def call(object)
        header.map { |attribute| object.send(attribute.name) }
      end

      # @api private
      def identity(object)
        header.keys.map { |key| object.send(key.name) }
      end

    end # Dumper

  end # Mapper
end # ROM
