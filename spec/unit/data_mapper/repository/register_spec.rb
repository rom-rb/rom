require 'spec_helper'

describe Repository, '#register' do
  subject { object.register(relation_name, header) }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { mock }
  let(:adapter)  { mock(:gateway => relation) }
  let(:relation) { Axiom::Relation.new(header, EMPTY_ARRAY.each) }

  let(:relation_name) { :test }
  let(:header)        { [] }

  it "should register a new relation" do
    subject.get(relation_name).should be(relation)
  end
end
