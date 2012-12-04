module DataMapper

  # Relationship
  #
  # @abstract
  #
  # @api private
  class Relationship

    include AbstractType

    # Returns foreign key name for the given class name
    #
    # @return [Symbol]
    #
    # @api private
    #
    def self.foreign_key_name(class_name)
      Inflector.foreign_key(class_name).to_sym
    end

    include Equalizer.new(:name, :source_model, :target_model, :source_key, :target_key)

    # Name of the relationship
    #
    # @return [Symbol]
    #
    # @api private
    attr_reader :name

    # Source model for the relationship
    #
    # @return [Class]
    #
    # @api private
    attr_reader :source_model

    # Target model for the relationship
    #
    # @return [Class]
    #
    # @api private
    attr_reader :target_model

    # Source key
    #
    # @return [Symbol,nil]
    #
    # @api private
    attr_reader :source_key

    # Target key
    #
    # @return [Symbol,nil]
    #
    # @api private
    attr_reader :target_key

    # Name of the relationship pointing from source to intermediary
    #
    # @return [Symbol, nil]
    #
    # @api private
    attr_reader :through

    # Name of the relationship pointing from intermediary to target
    #
    # @return [Symbol, nil]
    #
    # @api private
    attr_reader :via

    # Min size of the relationship children
    #
    # @return [Fixnum]
    #
    # @api private
    attr_reader :min

    # Max size of the relationship children
    #
    # @return [Fixnum]
    #
    # @api private
    attr_reader :max

    # Additional operation that must be evaluated on the relation
    #
    # @return [Proc,nil]
    #
    # @api private
    attr_reader :operation

    # Raw hash with options
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :options

    # The information needed to perform this relationship's join
    #
    # @return [nil]
    #   if this relationship hasn't been finalized yet
    #
    # @return [JoinDefinition]
    #   the object defining how to perform the join
    #
    # @api private
    attr_reader :join_definition

    # Initializes relationship options instance
    #
    # @param [#to_sym] name
    # @param [Class] source model
    # @param [Class] target model
    # @param [#to_hash] options
    #
    # @return [undefined]
    #
    # @api private
    def initialize(name, source_model, target_model, options = {})
      @name         = name.to_sym
      @options      = options.to_hash

      @source_model = source_model
      @target_model = target_model || options.fetch(:model)
      @source_key   = Array(options[:source_key] || default_source_key).freeze
      @target_key   = Array(options[:target_key] || default_target_key).freeze

      @through      = options[:through]
      @via          = options[:via]
      @operation    = options[:operation]

      @min = options.fetch(:min, 1)
      @max = options.fetch(:max, 1)
    end

    def finalize(mapper_registry)
      return self if @finalized
      finalize_join_definition(mapper_registry)
      @finalized = true
      self
    end

    # Returns if the target is a collection or a single object
    #
    # @return [Boolean]
    #
    # @api private
    def collection_target?
      false
    end

    private

    DEFAULT_SOURCE_KEY = [ :id ].freeze
    DEFAULT_TARGET_KEY = [].freeze

    # Returns default name of the source key
    #
    # @return [Symbol,nil]
    #
    # @api private
    def default_source_key
      DEFAULT_SOURCE_KEY
    end

    # Returns default name of the target key
    #
    # @return [Symbol,nil]
    #
    # @api private
    def default_target_key
      DEFAULT_TARGET_KEY
    end

    def finalize_join_definition(mapper_registry)
      left  = join_side(mapper_registry[source_model], source_key)
      right = join_side(mapper_registry[target_model], target_key)

      @join_definition = JoinDefinition.new(left, right)
    end

    def join_side(mapper, key)
      JoinDefinition::Side.new(mapper.relation, key)
    end
  end # class Relationship
end # module DataMapper
