module DataMapper
  class Mapper

    # AttributeSet
    #
    # @api private
    class AttributeSet
      include Enumerable

      # @api private
      def initialize
        @attributes = {}
      end

      # @api public
      def finalize
        each { |attribute| attribute.finalize }
      end

      # @api public
      def alias_index(prefix, excluded = [])
        primitives.each_with_object({}) { |attribute, index|
          next if excluded.include?(attribute.name)
          index[attribute.field] = attribute.aliased_field(prefix)
        }
      end

      # @api private
      def merge(other)
        instance = self.class.new
        each       { |attribute| instance << attribute.clone(:to => attribute.field) }
        other.each { |attribute| instance << attribute.clone(:to => attribute.field) }
        instance
      end

      # TODO find a better name and implementation
      def remap(aliases)
        instance = self.class.new

        aliases.each do |name, field|
          attribute = for_field(name)
          if attribute
            instance << attribute.clone(:to => field)
          end
        end

        each { |attribute| instance << attribute.clone unless instance[attribute.name] }

        instance
      end

      # TODO find a better name and implementation
      def for_field(field)
        detect { |attribute| attribute.field == field }
      end

      def <<(attribute)
        @attributes[attribute.name] = attribute
        self
      end

      # @api private
      def add(*args)
        self << Attribute.build(*args)
      end

      # @api private
      def includes?(attribute)
        self[attribute.name].equal?(attribute)
      end

      # @api private
      def [](name)
        @attributes[name]
      end

      # @api public
      def each
        return to_enum unless block_given?
        @attributes.each_value { |attribute| yield attribute }
        self
      end

      # @api public
      def field_name(attribute_name)
        self[attribute_name].field
      end

      # @api public
      def key_names
        key.map(&:name)
      end

      # @api private
      def header
        @header ||= primitives.map(&:header)
      end

      # @api private
      def primitives
        @primitives ||= select(&:primitive?)
      end

      # @api private
      def fields
        header.map(&:first)
      end

      # @api private
      def load(tuple)
        each_with_object({}) do |attribute, attributes|
          attributes[attribute.name] = attribute.load(tuple)
        end
      end

      # @api private
      def key
        select(&:key?)
      end
    end # class AttributeSet
  end # class Mapper
end # module DataMapper
