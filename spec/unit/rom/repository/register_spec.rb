require 'spec_helper'

describe Repository, '#register' do
  subject { object.register(relation_name, header) }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { :bigdata }
  let(:adapter)  { fake(:adapter, :gateway => relation) { Axiom::Adapter::InMemory } }
  let(:relation) { Axiom::Relation.new(header, EMPTY_ARRAY.each) }

  let(:relation_name) { :test }
  let(:header)        { [] }

  it "should register a new relation" do
    expect(subject.get(relation_name)).to be(relation)
  end
end
