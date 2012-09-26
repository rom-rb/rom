module DataMapper

  module Model

    def self.included(model)
      model.send(:include, Virtus)
    end

  end # module Model
end # module DataMapper
