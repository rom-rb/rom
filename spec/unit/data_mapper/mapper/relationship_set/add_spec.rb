require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#add' do
  let(:relationships) { described_class.new }
  let(:name)          { :address }
  let(:type)          { mock('type') }
  let(:options)       { { :type => type } }
  let(:relationship)  { mock('address') }

  it "adds a new relationship" do
    type.should_receive(:new).with(name, options).and_return(relationship)
    relationships.add(name, options)
    relationships[name].should be(relationship)
  end
end
