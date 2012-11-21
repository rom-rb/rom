module DataMapper
  class Mapper

    # AttributeSet
    #
    # @api private
    class AttributeSet

      include Enumerable

      include Equalizer.new(:attributes)

      # The set's attributes in a hash
      #
      # @return [Hash]
      #
      # @api private
      attr_reader :attributes

      # Initialize an empty set of attributes
      #
      # @api private
      def initialize
        @attributes = {}
      end

      # Finalize this set of attributes
      #
      # @return [self]
      #
      # @api private
      def finalize
        each { |attribute| attribute.finalize }
        self
      end

      # Aliases for a given prefix and list of names to exclude
      #
      # @param [Symbol] prefix
      #   the prefix used for aliasing non-excluded fields
      #
      # @param [Array] excluded
      #   the list of fields to exclude from aliasing
      #
      # @return [Hash]
      #
      # @api private
      def alias_index(prefix, excluded = [])
        primitives.each_with_object({}) { |attribute, index|
          next if excluded.include?(attribute.name)
          index[attribute.field] = attribute.aliased_field(prefix)
        }
      end

      # Return the result of merging within a new instance
      #
      # @param [AttributeSet] other
      #   the instance to merge
      #
      # @return [AttributeSet]
      #
      # @api private
      def merge(other)
        instance = self.class.new

        operation = lambda { |attribute| instance << attribute.clone }

        each(&operation)
        other.each(&operation)

        instance
      end

      # Return an AttributeSet matching the given aliases
      #
      # TODO find a better name and implementation
      #
      # @param [Hash] aliases
      #
      # @return [AttributeSet]
      #
      # @api private
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

      # Finds an attribute matching the given field name
      #
      # TODO find a better name and implementation
      #
      # @param [Symbol] field
      #   the name of the attribute's field
      #
      # @return [Attribute]
      #
      # @api private
      def for_field(field)
        detect { |attribute| attribute.field == field }
      end

      # Add an attribute to the set
      #
      # @param [Attribute] attribute
      #   the attribute to add
      #
      # @return [self]
      #
      # @api private
      def <<(attribute)
        @attributes[attribute.name] = attribute
        self
      end

      # Build and add an Attribute based on the given args
      #
      # @see Attribute.build
      #
      # @return [Attribute]
      #
      # @api private
      def add(*args)
        self << Attribute.build(*args)
      end

      # Tests wether attribute is included in the set
      #
      # @param [Attribute] attribute
      #   the attribute to lookup
      #
      # @return [Boolean]
      #   true if attribute is included, false otherwise
      #
      # @api private
      def includes?(attribute)
        self[attribute.name].equal?(attribute)
      end

      # Return the attribute with the given name
      #
      # @param [Symbol] name
      #   the attribute's name
      #
      # @return [Attribute, nil]
      #   the attribute if present, nil otherwise
      #
      # @api private
      def [](name)
        @attributes[name]
      end

      # Iterate over all attributes
      #
      # @example
      #
      #   attributes = DataMapper[User].attributes
      #   attributes.each do |attribute|
      #     puts attribute.name
      #   end
      #
      # @return [self]
      #
      # @api public
      def each
        return to_enum unless block_given?
        @attributes.each_value { |attribute| yield attribute }
        self
      end

      # Return the field name used for the given attribute_name
      #
      # @example
      #
      #   attributes = DataMapper[User].attributes
      #   attributes.field_name(:name)
      #
      # @param [Symbol] attribute_name
      #   the attribute's name
      #
      # @return [Symbol, nil]
      #   the attribute's field name if present, nil otherwise
      #
      # @api public
      def field_name(attribute_name)
        self[attribute_name].field
      end

      # Return all key attribute names
      #
      # @example
      #
      #   attributes = DataMapper[User].attributes
      #   attributes.key_names
      #
      # @return [Array]
      #
      # @api public
      def key_names
        key.map(&:name)
      end

      # Return a nested array representing the header
      #
      # @return [Array<Array(Symbol, Class)>]
      #
      # @api private
      def header
        @header ||= primitives.map(&:header)
      end

      # Return all primitive attributes
      #
      # @return [Array<Attribute::Primitive>]
      #
      # @api private
      def primitives
        @primitives ||= select(&:primitive?)
      end

      # Return all field names
      #
      # @return [Array<Symbol>]
      #
      # @api private
      def fields
        header.map(&:first)
      end

      # Load a tuple
      #
      # @see Attribute#load
      #
      # @param [(#each, #[])] tuple
      #   the tuple to load
      #
      # @return [Hash]
      #
      # @api private
      def load(tuple)
        each_with_object({}) do |attribute, attributes|
          attributes[attribute.name] = attribute.load(tuple)
        end
      end

      # Return all key attributes
      #
      # @return [Array<Attribute>]
      #
      # @api private
      def key
        select(&:key?)
      end
    end # class AttributeSet
  end # class Mapper
end # module DataMapper
