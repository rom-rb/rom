require 'spec_helper'

describe Relation::Mapper, '#include' do
  subject { object.include(name) }

  let(:object) { mock_mapper(model).new(DM_ENV, relation) }

  let(:model)        { mock_model(:User) }
  let(:relation)     { mock_relation(:relation) }
  let(:name)         { :address }
  let(:relationship) { mock('relationship') }
  let(:mapper)       { mock('user_X_address_mapper') }

  before do
    object.stub!(:relationships).and_return(:address => relationship)
  end

  it "returns mapper for address relationship from mapper registry" do
    DM_ENV.registry.should_receive(:[]).with(model, relationship).
      and_return(mapper)

    subject.should be(mapper)
  end
end
