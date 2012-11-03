require 'spec_helper'

describe Mapper::Relation, '#order' do
  subject { object.order(*names) }

  let(:object)     { mock_mapper(model, attributes).new(relation) }

  let(:model)      { mock_model(:User) }
  let(:attributes) { [ id, name, age ] }
  let(:id)         { Mapper::Attribute.build(:id, :type => Integer) }
  let(:age)        { Mapper::Attribute.build(:age, :type => Integer) }
  let(:name)       { Mapper::Attribute.build(:name, :type => String) }

  let(:relation)   { mock('relation') }
  let(:sorted)     { mock('sorted') }
  let(:names)      { [ :age, :name ] }

  before do
    relation.should_receive(:order).with(*[ :age, :name, :id ]).and_return(sorted)
  end

  it { should be_instance_of(object.class) }

  its(:relation)   { should be(sorted) }
  its(:attributes) { should be(object.attributes) }
end
