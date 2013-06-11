require 'spec_helper'

describe Repository, '#register' do
  subject { object.get(relation_name) }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { :bigdata }
  let(:adapter)  { fake(:adapter, :gateway => relation) { Axiom::Adapter::InMemory } }
  let(:relation) { Axiom::Relation.new(header, EMPTY_ARRAY.each) }

  let(:relation_name) { :test }
  let(:header)        { [] }

  before do
    object.register(relation_name, header)
  end

  it { should be(relation) }
end
