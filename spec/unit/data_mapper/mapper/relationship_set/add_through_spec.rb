require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#add_through' do
  let(:relationships) { described_class.new }
  let(:source)        { mock('source',       :name => :source) }
  let(:relationship)  { mock('relationship', :name => :relationship) }
  let(:operation)     { Proc.new {} }

  before { relationships << source }

  it "adds a relationship inherting from the source" do
    relationships[:source].should_receive(:inherit).
      with(:relationship, operation).and_return(relationship)

    relationships.add_through(:source, :relationship, &operation)

    relationships[:relationship].should be(relationship)
  end
end
