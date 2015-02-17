module ROM
  class Header
    # An attribute provides information about a specific attribute in a tuple
    #
    # This may include information about how an attribute should be renamed,
    # or how its value should coerced.
    #
    # More complex attributes describe how an attribute should be transformed.
    #
    # @private
    class Attribute
      include Equalizer.new(:name, :key, :type)

      # @return [Symbol] name of an attribute
      #
      # @api private
      attr_reader :name

      # @return [Symbol] key of an attribute that corresponds to tuple attribute
      #
      # @api private
      attr_reader :key

      # @return [Symbol] type identifier (defaults to :object)
      #
      # @api private
      attr_reader :type

      # @return [Hash] additional meta information
      #
      # @api private
      attr_reader :meta

      # Return attribute class for a give meta hash
      #
      # @param [Hash] meta hash with type information and optional transformation info
      #
      # @return [Class]
      #
      # @api private
      def self.[](meta)
        type = meta[:type]

        if type.equal?(:hash)
          meta[:wrap] ? Wrap : Hash
        elsif type.equal?(:array)
          meta[:group] ? Group : Array
        else
          self
        end
      end

      # Coerce an array with attribute meta-data into an attribute object
      #
      # @param [Array<Symbol,Hash>] input attribute name/options pair
      #
      # @return [Attribute]
      #
      # @api private
      def self.coerce(input)
        name = input[0]
        meta = (input[1] || {}).dup

        meta[:type] ||= :object

        if meta.key?(:header)
          meta[:header] = Header.coerce(meta[:header], meta[:model])
        end

        self[meta].new(name, meta)
      end

      # @api private
      def initialize(name, meta)
        @name = name
        @meta = meta
        @key = meta.fetch(:from) { name }
        @type = meta.fetch(:type)
      end

      # Return if an attribute has a specific type identifier
      #
      # @api private
      def typed?
        type != :object
      end

      # Return if an attribute should be aliased
      #
      # @api private
      def aliased?
        key != name
      end

      # Return :key-to-:name mapping hash
      #
      # @return [Hash]
      #
      # @api private
      def mapping
        { key => name }
      end
    end

    # Embedded attribute is a special attribute type that has a header
    #
    # This is the base of complex attributes like Hash or Group
    #
    # @private
    class Embedded < Attribute
      include Equalizer.new(:name, :key, :type, :header)

      # return [Header] header of an attribute
      #
      # @api private
      attr_reader :header

      # @api private
      def initialize(*)
        super
        @header = meta.fetch(:header)
      end

      # Return tuple keys from the header
      #
      # @return [Array<Symbol>]
      #
      # @api private
      def tuple_keys
        header.tuple_keys
      end
    end

    # Array is an embedded attribute type
    Array = Class.new(Embedded)

    # Hash is an embedded attribute type
    Hash = Class.new(Embedded)

    # Wrap is a special type of Hash attribute that requires wrapping
    # transformation
    Wrap = Class.new(Hash)

    # Group is a special type of Array attribute that requires grouping
    # transformation
    Group = Class.new(Array)
  end
end
