require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#<<' do
  let(:relationships) { described_class.new }
  let(:name)          { :address }
  let(:relationship)  { mock('address', :name => name) }

  it "adds a new relationship" do
    relationships << relationship
    relationships[name].should be(relationship)
  end
end
