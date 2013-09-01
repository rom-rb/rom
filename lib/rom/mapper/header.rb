# encoding: utf-8

module ROM
  class Mapper

    # Mapper header wrapping axiom header and providing mapping information
    #
    # @private
    class Header
      include Enumerable, Concord.new(:header, :attributes), Adamantium

      # Build a header
      #
      # @api private
      def self.build(input, options = {})
        return input if input.is_a?(self)

        keys       = options.fetch(:keys, [])
        header     = Axiom::Relation::Header.coerce(input, keys: keys)

        mapping    = options.fetch(:map, {})
        attributes = header.each_with_object({}) { |field, object|
          attribute = Attribute.coerce(field, mapping[field.name])
          object[attribute.name] = attribute
        }

        new(header, attributes)
      end

      # Return attribute mapping
      #
      # @api private
      def mapping
        each_with_object({}) { |attribute, hash|
          hash.update attribute.mapping
        }
      end
      memoize :mapping

      # Return all key attributes
      #
      # @return [Array<Attribute>]
      #
      # @api public
      def keys
        # FIXME: find a way to simplify this
        header.keys.flat_map { |key_header|
          key_header.flat_map { |key|
            attributes.values.select { |attribute|
              attribute.tuple_key == key.name
            }
          }
        }
      end
      memoize :keys

      # Return attribute with the given name
      #
      # @return [Attribute]
      #
      # @api public
      def [](name)
        attributes.fetch(name)
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
        attributes.each_value(&block)
        self
      end

    end # Header

  end # Mapper
end # ROM
