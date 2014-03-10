# encoding: utf-8

module ROM
  class Mapper

    # Represents a mapping attribute
    #
    # @private
    class Attribute < Struct.new(:name, :field)
      include Adamantium, Equalizer.new(:name, :field), Morpher::NodeHelpers

      # @api private
      def self.coerce(input, mapping = nil)
        field = Axiom::Attribute.coerce(input)
        new(mapping || field.name, field)
      end

      # @api private
      def to_ast
        s(:block, s(:key_fetch, name), s(:key_dump, name))
      end
      memoize :to_ast

      # @api private
      def mapping
        { tuple_key => name }
      end

      # @api private
      def tuple_key
        field.name
      end

    end # Attribute

  end # Mapper
end # ROM
