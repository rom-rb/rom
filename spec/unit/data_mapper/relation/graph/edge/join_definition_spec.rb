require 'spec_helper'

describe Relation::Graph::Edge, '#join_definition' do
  subject { object.join_definition }

  let(:object) { described_class.new(name, left, right) }

  let(:name)            { mock('orders', :relationship => relationship, :to_sym => :orders) }
  let(:relationship)    { mock('relationship', :join_definition => join_definition) }
  let(:join_definition) { mock('join_definition') }

  let(:left)            { mock('users', :name => source_name, :aliases => source_aliases) }
  let(:source_name)     { mock('source_name') }
  let(:source_aliases)  { mock('source_aliases', :join => mock) }
  let(:right)           { mock('orders', :aliases => mock) }

  it { should be(join_definition) }
end
