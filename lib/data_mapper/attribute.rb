module DataMapper

  # Class representing a relation's attribute within a mapper
  #
  # @abstract
  #
  # @api private
  class Attribute

    include AbstractType

    include Equalizer.new(:name, :type, :field, :options)

    # The attribute's name
    #
    # @example
    #
    #   attribute = DataMapper[Person].attributes[:name]
    #   attribute.name
    #
    # @return [Symbol]
    #
    # @api public
    attr_reader :name

    # The attribute's type
    #
    # @example
    #
    #   attribute = DataMapper[Person].attributes[:name]
    #   attribute.type
    #
    # @return [Class]
    #
    # @api public
    attr_reader :type

    # The attribute's field name
    #
    # @example
    #
    #   attribute = DataMapper[Person].attributes[:name]
    #   attribute.field
    #
    # @return [Symbol]
    #
    # @api public
    attr_reader :field

    # The attribute's options
    #
    # @example
    #
    #   attribute = DataMapper[Person].attributes[:name]
    #   attribute.options
    #
    # @return [Hash]
    #
    # @api public
    attr_reader :options

    # The primitive attribute types
    #
    # @api private
    PRIMITIVES = [ String, Time, Integer, Float, BigDecimal, DateTime, Date, Class, TrueClass, Numeric, Object ].freeze

    # Option keys that can't be changed with {#clone}
    #
    # @api private
    STABLE_OPTIONS = [ :type, :collection ].freeze

    # Instantiate a concrete attribute subclass based on the given options
    #
    # @example
    #
    #   DataMapper::Mapper::Attribute.build(:name, :type => String)
    #
    # @param [Symbol] name
    #   the attribute's name
    #
    # @param [Hash] options
    #   the attribute's options
    # @option options [String] :to
    #   the field name to map to
    # @option options [String] :key
    #   true if this attribute is (part of) the key
    # @option options [String] :type
    #   the attribute's type
    # @option options [String] :collection
    #   true if this attribute is a collection
    #
    # @return [Attribute]
    #   a concrete subclass based on the given options
    #
    # @api public
    def self.build(name, options = EMPTY_HASH)
      klass = if PRIMITIVES.include?(options[:type])
                Attribute::Primitive
              elsif options[:collection]
                Attribute::EmbeddedCollection
              else
                Attribute::EmbeddedValue
              end

      attribute = klass.new(name, options)
      attribute.extend(Coercible) if options[:coercion_method]
      attribute
    end

    # Return a clone of +attribute+ but with the given +clone_options+ merged
    #
    # The method will not change the +:type+ and +:collection+ options
    #
    # @see Attribute.build
    # @see STABLE_OPTIONS
    #
    # @param [Attribute] attribute
    #   the attribute instance to clone
    #
    # @param [Hash] clone_options
    #   the options accepted by {.build}
    #
    # @return [Attribute]
    #
    # @api private
    def self.clone(attribute, clone_options = EMPTY_HASH)
      name, options = attribute.name, attribute.options
      build(name, options.merge(cloneable_options(clone_options)))
    end

    # Strip stable options from options passed to #clone
    #
    # @param [Hash] options
    #   the options for a cloned attribute
    #
    # @return [Hash]
    #   the passed in options minus keys in {STABLE_OPTIONS}
    #
    # @api private
    def self.cloneable_options(options)
      options.reject { |key, _| STABLE_OPTIONS.include?(key) }
    end

    private_class_method :cloneable_options

    # Initialize a new attribute instance
    #
    # @see Attribute.build
    #
    # @return [undefined]
    #
    # @api private
    def initialize(name, options)
      @name    = name
      @field   = options.fetch(:to, @name)
      @key     = options.fetch(:key, false)
      @options = options.dup.freeze
    end

    # Finalize this attribute
    #
    # This is a noop. Concrete subclasses may overwrite this.
    #
    # @return [self]
    #
    # @api private
    def finalize(*)
      self # noop
    end

    # Load this attribute's value from a tuple
    #
    # @abstract
    #
    # @param [(#each, #[])] tuple
    #   the tuple to load
    #
    # @raise NotImplementedError
    #
    # @return [undefined]
    #
    # @api private
    abstract_method :load

    # Tests wether the attribute is (part of) a key
    #
    # @return [Boolean]
    #   true if attribute is (part of) a key, false otherwise
    #
    # @api private
    def key?
      @key
    end

    # Tests wether the attribute's type is primitive
    #
    # @return [Boolean]
    #   true if attribute's type is primitive, false otherwise
    #
    # @api private
    def primitive?
      false
    end

    # Return a cloned instance but with the given options merged
    #
    # The method will not change the +:type+ and +:collection+ options
    #
    # @see Attribute.build
    # @see STABLE_OPTIONS
    #
    # @param [Hash] options
    #   the options accepted by {Attribute.build} minus {STABLE_OPTIONS}
    #
    # @return [Attribute]
    #
    # @api private
    def clone(options = EMPTY_HASH)
      self.class.clone(self, options)
    end

  end # class Attribute

end # module DataMapper
