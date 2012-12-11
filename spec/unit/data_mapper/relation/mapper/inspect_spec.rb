require 'spec_helper'

describe Relation::Mapper, '#inspect' do
  subject { object.inspect }

  let(:object)     { mock_mapper(model).new(relation) }
  let(:relation)   { mock('relation') }
  let(:repository) { :test }
  let(:model)      { mock_model('User') }

  it { should eql('<#UserMapper @model=User @relation_name=users @repository=test>') }
end
