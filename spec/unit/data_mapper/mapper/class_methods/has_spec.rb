require 'spec_helper'

describe Mapper, '.has' do
  subject { described_class.has(cardinality, name, model) }

  let(:cardinality) { 1 }
  let(:name)        { :stuff }
  let(:model)       { mock('TestModel') }

  let(:relationship) { mock('relationship', :name => name) }

  it "uses relationship builder to setup relationship" do
    Relationship::Builder::Has.should_receive(:build).
      with(described_class, cardinality, name, model).
      and_return(relationship)

    subject.relationships[name].should be(relationship)
  end
end
