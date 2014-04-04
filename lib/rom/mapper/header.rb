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
      def self.build(input)
        if input.is_a?(self)
          input
        else
          new(input.map { |args| Attribute.build(*args) })
        end
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

      # TODO: this should receive a hash with header objects already
      def wrap(other)
        new_attributes = other.map { |name, mapper| mapper.attribute(Attribute::EmbeddedValue, name) }
        self.class.new((attributes + new_attributes).uniq)
      end

      # TODO: this should receive a hash with header objects already
      def group(other)
        new_attributes = other.map { |name, mapper| mapper.attribute(Attribute::EmbeddedCollection, name) }
        self.class.new((attributes + new_attributes).uniq)
      end

      # @api private
      def join(other)
        self.class.new((attributes + other.attributes).uniq)
      end

      # @api private
      def project(names)
        self.class.new(select { |attribute| names.include?(attribute.name) })
      end

      # @api private
      def rename(names)
        self.class.new(map { |attribute| names[attribute.name] ? attribute.rename(names[attribute.name]) : attribute })
      end

    end # Header

  end # Mapper
end # ROM
