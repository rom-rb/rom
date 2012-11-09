require 'spec_helper'

describe RelationRegistry::RelationEdge, '#target_name' do
  subject { object.target_name }

  let(:object) { described_class.new(name, left, right, join_key_map) }

  let(:name)         { :orders }
  let(:left)         { mock('users') }
  let(:right)        { mock('orders', :name => target_name) }
  let(:target_name)  { mock('target_name') }
  let(:join_key_map) { mock('join_key_map') }

  it { should be(target_name) }
end
