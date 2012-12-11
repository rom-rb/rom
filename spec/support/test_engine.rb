class TestEngine < DataMapper::Engine::Veritas::Engine
  def initialize(uri)
    @relations = DataMapper::Relation::Graph.new(self)
  end
end
