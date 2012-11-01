require 'spec_helper'

describe Mapper, '.belongs_to' do
  subject { described_class.belongs_to(name, model) }

  let(:name)  { :stuff }
  let(:model) { mock('TestModel') }

  let(:relationship) { mock('relationship', :name => name) }

  it "uses relationship builder to setup relationship" do
    Relationship::Builder::BelongsTo.should_receive(:build).
      with(described_class, name, model).
      and_return(relationship)

    subject.relationships[name].should be(relationship)
  end
end
