require 'spec_helper'

describe Mapper::Relation, '#include' do
  subject { object.include(name) }

  let(:object) { mock_mapper(model).new }

  let(:model)        { mock_model(:User) }
  let(:name)         { :address }
  let(:relationship) { mock('relationship') }
  let(:mapper)       { mock('user_X_address_mapper') }

  before do
    object.stub!(:relationships).and_return(:address => relationship)
  end

  it "returns mapper for address relationship from mapper registry" do
    Mapper.mapper_registry.should_receive(:[]).with(model, relationship).
      and_return(mapper)

    subject.should be(mapper)
  end
end
