require 'spec_helper'

describe RelationRegistry::RelationEdge, '#join_key_map' do
  subject { object.join_key_map }

  let(:object) { described_class.new(name, left, right, join_key_map) }

  let(:name)         { :orders }
  let(:left)         { mock('users', :name => source_name) }
  let(:right)        { mock('orders') }
  let(:source_name)  { mock('source_name')}
  let(:join_key_map) { mock('join_key_map') }

  it { should be(join_key_map) }
end
