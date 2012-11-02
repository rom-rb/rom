require 'spec_helper'

describe Mapper::Relation, '.finalize' do
  it 'registers mapper instance' do
    model = mock_model(:User)

    mapper_class = Class.new(described_class).
      model(model).relation_name(:users).repository(:test)


    mapper_class.model.should be(model)

    mapper_class.finalize

    mapper_class.should be_frozen

    Mapper.mapper_registry[model].should be_instance_of(mapper_class)
  end
end
