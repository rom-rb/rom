require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#finalize' do
  let(:relationships) { described_class.new }
  let(:address)       { mock('address', :name => :address) }
  let(:users)         { mock('users',   :name => :users) }

  before { relationships << address << users }

  it "finalizes its relationships" do
    address.should_receive(:finalize)
    users.should_receive(:finalize)

    relationships.finalize
  end
end
