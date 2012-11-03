require 'spec_helper'

describe Mapper::Relation, '#inspect' do
  subject { object.inspect }

  let(:object)     { mock_mapper(model).new(relation) }
  let(:relation)   { mock('relation') }
  let(:repository) { :test }
  let(:model)      { mock_model(:User) }

  it { should eql('<#UserMapper @model=User @relation_name=users @repository=test>') }
end
