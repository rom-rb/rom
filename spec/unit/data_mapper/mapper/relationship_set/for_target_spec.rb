require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#for_target' do
  subject { relationships.for_target(user_model) }

  let(:relationships) { described_class.new }
  let(:address)       { mock('address', :name => :address, :target_model => address_model) }
  let(:users)         { mock('users',   :name => :users, :target_model => user_model) }
  let(:address_model) { mock_model(:Address) }
  let(:user_model)    { mock_model(:User) }

  before { relationships << address << users }

  it { should have(1).items }
  it { should include(users) }
end
