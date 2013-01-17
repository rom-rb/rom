require 'spec_helper'

describe Engine::Veritas::Node, '#sort_by' do
  subject { object.sort_by(&block) }

  let(:object)   { described_class.new(:users, relation) }
  let(:relation) { mock('relation') }
  let(:sorted)   { mock('sorted') }
  let(:block)    { Proc.new {} }

  before do
    relation.should_receive(:sort_by).and_return(sorted)
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(sorted) }
  its(:header)   { should be(object.header) }
end
