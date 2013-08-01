# encoding: utf-8

require 'spec_helper'

describe Repository, '#get' do
  subject { object.get(relation_name) }

  let(:object) { described_class.build(name, uri) }
  let(:name)   { :bigdata }
  let(:uri)    { Addressable::URI.parse('memory://test') }

  let(:relation)      { Axiom::Relation::Base.new(relation_name, header) }
  let(:relation_name) { :test }
  let(:header)        { [] }

  before do
    object.register(relation_name, relation)
  end

  it { should eq(relation) }
end
