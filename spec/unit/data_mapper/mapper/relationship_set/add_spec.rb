require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#add' do
  let(:relationships) { described_class.new }
  let(:name)          { :address }
  let(:type)          { mock('type') }
  let(:options)       { mock('options', :type => type) }
  let(:relationship)  { mock('address') }

  it "adds a new relationship" do
    options.should_receive(:validate).ordered
    type.should_receive(:new).ordered.with(options).and_return(relationship)
    relationships.add(name, options)
    relationships[name].should be(relationship)
  end
end
