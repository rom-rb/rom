require 'spec_helper'

describe Relation::Mapper::RelationshipSet, '#[]' do
  subject { relationships[name] }

  let(:relationships) { described_class.new([relationship]) }
  let(:name)          { :address }
  let(:relationship)  { mock('address', :name => name) }

  it { should be(relationship) }
end
