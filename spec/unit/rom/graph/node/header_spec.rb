require 'spec_helper'

describe Graph::Node, '#header' do
  subject { object.header }

  let(:object)   { described_class.new(:users, relation, header) }
  let(:relation) { mock('relation') }
  let(:header)   { mock('header') }

  it { should be(header) }
end
