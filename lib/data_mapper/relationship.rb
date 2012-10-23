module DataMapper

  # Relationship
  #
  # TODO rethink Relationship::Options
  #
  # @api private
  class Relationship

    attr_reader :name
    attr_reader :options
    attr_reader :operation
    attr_reader :via
    attr_reader :source_key
    attr_reader :target_key
    attr_reader :source_model
    attr_reader :target_model
    attr_reader :hash

    def initialize(options)
      @options      = options
      @name         = @options.name
      @via          = @options.via
      @operation    = @options.operation
      @source_model = @options.source_model
      @target_model = @options.target_model
      @source_key   = @options.source_key || default_source_key
      @target_key   = @options.target_key || default_target_key

      @hash = @name.hash ^ @source_model.hash
    end

    # @api private
    def for_source(new_name, source_model)
      self.class.new(
        @options.class.new(
          new_name,
          source_model,
          target_model,
          :through      => options.via,
          :operation    => options.operation,
          :min          => options.min,
          :max          => options.max,
          :model        => source_model
        )
      )
    end

    # @api public
    def finalize
      self
    end

    def collection_target?
      false
    end

    def eql?(other)
      return false unless instance_of?(other.class)
      @name.eql?(other.name) && @source_model.eql?(other.source_model)
    end

    def ==(other)
      return false unless self.class <=> other.class
      @name == other.name && @source_model == other.source_model
    end
  end # class Relationship
end # module DataMapper
