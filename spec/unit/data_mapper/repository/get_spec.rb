require 'spec_helper'

describe Repository, '#register' do
  subject { object.get(relation_name) }

  let(:object)   { described_class.new(name, adapter) }
  let(:name)     { mock }
  let(:adapter)  { mock(:gateway => relation) }
  let(:relation) { Veritas::Relation.new(header, EMPTY_ARRAY.each) }

  let(:relation_name) { :test }
  let(:header)        { [] }

  before do
    object.register(relation_name, header)
  end

  it { should be(relation) }
end
