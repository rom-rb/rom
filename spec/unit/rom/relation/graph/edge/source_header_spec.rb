require 'spec_helper'

describe Relation::Graph::Edge, '#source_header' do
  subject { object.source_header }

  let(:object) { described_class.new(name, left, right) }

  let(:name)            { mock('orders', :relationship => relationship, :to_sym => :orders) }
  let(:relationship)    { mock('relationship', :join_definition => join_definition) }
  let(:join_definition) { mock('join_definition') }

  let(:left)            { mock('users', :name => source_name, :header => source_header) }
  let(:source_header)   { mock('source_header', :join => mock) }
  let(:right)           { mock('orders', :header => mock) }
  let(:source_name)     { mock('source_name') }

  it { should be(source_header) }
end
