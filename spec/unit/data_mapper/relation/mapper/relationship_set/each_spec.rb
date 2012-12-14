require 'spec_helper'

describe Relation::Mapper::RelationshipSet, '#each' do
  subject { relationships.each.to_a }

  let(:relationships) { described_class.new }
  let(:address)       { mock('address', :name => :address) }
  let(:users)         { mock('users',   :name => :users) }

  before { relationships << address << users }

  it { should have(2).items }
  it { should include(address) }
  it { should include(users) }
end
