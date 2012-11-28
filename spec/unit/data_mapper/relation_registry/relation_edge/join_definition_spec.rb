require 'spec_helper'

describe RelationRegistry::RelationEdge, '#join_definition' do
  subject { object.join_definition }

  let(:object) { described_class.new(name, left, right) }

  let(:name)            { mock('orders', :relationship => relationship, :to_sym => :orders) }
  let(:relationship)    { mock('relationship', :join_definition => join_definition) }
  let(:join_definition) { mock('join_definition') }

  let(:left)            { mock('users', :name => source_name) }
  let(:right)           { mock('orders') }
  let(:source_name)     { mock('source_name') }

  it { should be(join_definition) }
end
