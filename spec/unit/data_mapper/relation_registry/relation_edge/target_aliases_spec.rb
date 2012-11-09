require 'spec_helper'

describe RelationRegistry::RelationEdge, '#target_aliases' do
  subject { object.target_aliases }

  let(:object) { described_class.new(name, left, right, join_key_map) }

  let(:name)           { :orders }
  let(:left)           { mock('users') }
  let(:right)          { mock('orders', :aliases => target_aliases) }
  let(:target_aliases) { mock('target_aliases')}
  let(:join_key_map)   { mock('join_key_map') }

  it { should be(target_aliases) }
end
