require 'spec_helper'

describe RelationRegistry::RelationEdge, '#source_aliases' do
  subject { object.source_aliases }

  let(:object) { described_class.new(name, left, right, join_key_map) }

  let(:name)           { :orders }
  let(:left)           { mock('users', :aliases => source_aliases) }
  let(:right)          { mock('orders') }
  let(:source_aliases) { mock('source_aliases')}
  let(:join_key_map)   { mock('join_key_map') }

  it { should be(source_aliases) }
end
