require 'spec_helper'

describe Repository, '#register' do
  subject { object.get(relation_name) }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { :bigdata }
  let(:adapter)  { fake(:adapter, :gateway => relation) { Axiom::Adapter::InMemory } }
  let(:relation) { Axiom::Relation::Base.new(relation_name, header) }

  let(:relation_name) { :test }
  let(:header)        { [] }

  before do
    object.register(relation)
  end

  it { should be(relation) }
end
