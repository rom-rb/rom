require 'spec_helper'

describe Relation::Graph::Edge, '#target_header' do
  subject { object.target_header }

  let(:object) { described_class.new(name, left, right) }

  let(:name)            { mock('orders', :relationship => relationship, :to_sym => :orders) }
  let(:relationship)    { mock('relationship', :join_definition => join_definition) }
  let(:join_definition) { mock('join_definition') }

  let(:left)            { mock('users', :name => source_name, :header => source_header) }
  let(:source_name)     { mock('source_name') }
  let(:source_header)   { mock('source_header', :join => mock) }
  let(:right)           { mock('orders', :header => target_header) }
  let(:target_header)   { mock('target_header') }

  it { should be(target_header) }
end
