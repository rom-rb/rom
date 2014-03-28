# encoding: utf-8

module ROM
  class Mapper

    # Mapper header wrapping axiom header and providing mapping information
    #
    # @private
    class Header
      include Enumerable, Concord.new(:attributes), Adamantium, Morpher::NodeHelpers

      # Build a header
      #
      # @api private
      def self.build(attributes)
        new(attributes.map { |input| Attribute.build(*input) })
      end

      # Return attribute mapping
      #
      # @api private
      def mapping
        each_with_object({}) { |attribute, hash| hash.update(attribute.mapping) }
      end
      memoize :mapping

      # Return all key attributes
      #
      # @return [Array<Attribute>]
      #
      # @api public
      def keys
        select(&:key?)
      end
      memoize :keys

      def to_ast
        s(:hash_transform, *map(&:to_ast))
      end
      memoize :to_ast

      # Return attribute with the given name
      #
      # @return [Attribute]
      #
      # @api public
      def [](name)
        detect { |attribute| attribute.name == name } || raise(KeyError)
      end

      # Return attribute names
      #
      # @api private
      def attribute_names
        map(&:name)
      end

      # Iterate over attributes
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        attributes.each(&block)
        self
      end

      def wrap(other)
        new_attributes = other.map { |name, mapper| mapper.attribute(name) }
        self.class.new(attributes + new_attributes)
      end

      def join(other)
        self.class.new((attributes + other.attributes).uniq)
      end

      def project(names)
        self.class.new(select { |attribute| names.include?(attribute.name) })
      end

    end # Header

  end # Mapper
end # ROM
