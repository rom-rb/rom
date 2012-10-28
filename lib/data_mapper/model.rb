module DataMapper

  module Model

    # TODO: add specs
    def self.included(model)
      model.send(:include, Virtus)
    end

  end # module Model
end # module DataMapper
