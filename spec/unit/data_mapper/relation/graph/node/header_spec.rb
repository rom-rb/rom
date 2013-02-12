require 'spec_helper'

describe Relation::Graph::Node, '#header' do
  subject { object.header }

  let(:object)   { described_class.new(:users, relation, header) }
  let(:relation) { mock }
  let(:header)   { mock }

  it { should be(header) }
end
