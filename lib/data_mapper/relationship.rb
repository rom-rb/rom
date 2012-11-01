module DataMapper

  # Relationship
  #
  # @api private
  class Relationship
    include Equalizer.new(:name, :source_model, :target_model)

    attr_reader :name
    attr_reader :options
    attr_reader :operation
    attr_reader :via
    attr_reader :source_key
    attr_reader :target_key
    attr_reader :source_model
    attr_reader :target_model

    # Initialize a relationship object
    #
    # @param [Options]
    #
    # @return [undefined]
    #
    # @api private
    def initialize(options)
      @options      = options
      @name         = @options.name
      @via          = @options.via
      @operation    = @options.operation
      @source_model = @options.source_model
      @target_model = @options.target_model
      @source_key   = @options.source_key
      @target_key   = @options.target_key
    end

    # Returns if the target is a collection or a single object
    #
    # @return [Boolean]
    #
    # @api public
    def collection_target?
      false
    end
  end # class Relationship
end # module DataMapper
