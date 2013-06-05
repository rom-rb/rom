require 'spec_helper'

describe Repository, '#register' do
  subject { object.register(relation_name, header, :keys => keys) }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { :bigdata }
  let(:adapter)  { Axiom::Adapter::InMemory.new('memory://localhost') }

  let(:relation_name) { :test }
  let(:header)        { [ [:id, Integer], [:name, String] ] }
  let(:keys)          { [ :id ] }

  it "registers a new relation" do
    relation = subject.get(relation_name)

    expect(relation).to be_instance_of(Axiom::Relation::Base)
    expect(relation.header.keys).to include(:id)
  end
end
