require 'spec_helper'

describe RelationRegistry::Edge, '#source_aliases' do
  subject { object.source_aliases }

  let(:object) { described_class.new(name, left, right) }

  let(:name)            { mock('orders', :relationship => relationship, :to_sym => :orders) }
  let(:relationship)    { mock('relationship', :join_definition => join_definition) }
  let(:join_definition) { mock('join_definition') }

  let(:left)            { mock('users', :name => source_name, :aliases => source_aliases) }
  let(:source_aliases)  { mock('source_aliases') }
  let(:right)           { mock('orders') }
  let(:source_name)     { mock('source_name') }

  it { should be(source_aliases) }
end
