require 'spec_helper'

describe Repository, '#register' do
  subject { object.register(relation) }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { :bigdata }
  let(:adapter)  { Axiom::Adapter::InMemory.new('memory://localhost') }

  let(:relation_name) { :test }
  let(:relation)      { Axiom::Relation::Base.new(relation_name, Axiom::Relation::Header.coerce(header, :keys => keys))}
  let(:header)        { [ [:id, Integer], [:name, String] ] }
  let(:keys)          { [ :id ] }

  it "registers a new relation" do
    relation = subject.get(relation_name)

    expect(relation).to be(relation)
    expect(relation.header.keys).to include(:id)
  end
end
