module DataMapper

  # Abstract Mapper class
  #
  # @abstract
  class Mapper
    include Enumerable

    # Set or return the model for this mapper
    #
    # @api public
    def self.model(model=nil)
      @model ||= model
    end

    # Set or return the model for this mapper
    #
    # @api public
    def self.name(name=nil)
      @name ||= name
    end

    # Configure mapping of an attribute
    #
    # @example
    #
    #   class User::Mapper < DataMapper::Mapper
    #     map :name, :to => :username
    #   end
    #
    # @api public
    def self.map(*args)
      attributes.add(*args)
      self
    end

    # @api private
    def self.attributes
      @attributes ||= AttributeSet.new
    end

    # Load a domain object
    #
    # @api private
    def load(tuple)
      raise NotImplementedError, "#{self.class}#load is not implemented"
    end

    # AttributeSet
    #
    # @api private
    class AttributeSet

      # Attribute
      #
      # @api private
      class Attribute

        # @api private
        attr_reader :name

        # @api private
        attr_reader :type

        # @api private
        attr_reader :map_to

        # @api private
        def initialize(name, options = {})
          @name   = name
          @map_to = options.fetch(:to, @name)
          @type   = options.fetch(:type, Object)
        end

      end # class Attribute

      # @api private
      def initialize
        @_attributes = {}
      end

      # @api private
      def header
        @header ||= @_attributes.values.map do |attribute|
          [ attribute.map_to, attribute.type ]
        end
      end

      # @api private
      def map(tuple)
        @_attributes.values.each_with_object({}) do |attribute, attributes|
          attributes[attribute.name] = tuple[attribute.map_to]
        end
      end

      # @api private
      def add(*args)
        @_attributes[args[0]] = Attribute.new(args[0], args[1]||{})
        self
      end

      # @api private
      def [](name)
        @_attributes[name]
      end

    end # class AttributeSet

  end # class Mapper
end # module DataMapper
