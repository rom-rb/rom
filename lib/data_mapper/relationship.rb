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

    def initialize(options)
      @options      = options
      @name         = @options.name
      @via          = @options.via
      @operation    = @options.operation
      @source_key   = @options.source_key
      @target_key   = @options.target_key
      @source_model = @options.source_model
      @target_model = @options.target_model
    end

    # @api public
    def finalize
      self
    end

    def collection_target?
      false
    end
  end # class Relationship
end # module DataMapper
