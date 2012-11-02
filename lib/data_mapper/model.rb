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
      super
      self
    end

  end # module Model

end # module DataMapper
