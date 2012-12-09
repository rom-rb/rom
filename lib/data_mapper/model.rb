module DataMapper

  # Extend class with attribute definition DSL
  #
  module Model

    # Extend given model with Virtus
    #
    # @param [Class]
    #
    # @return [self]
    #
    # @api private
    def self.included(model)
      model.send(:include, Virtus)
      descendants << model
      super
      self
    end

    # @api public
    def self.descendants
      @descendants ||= []
    end

  end # module Model

end # module DataMapper
