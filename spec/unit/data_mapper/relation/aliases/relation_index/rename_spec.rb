require 'spec_helper'

describe Relation::Aliases::RelationIndex, '#rename' do
  subject { object.rename(aliases) }

  let(:object)  { described_class.new({ :users => 1 }) }
  let(:aliases) { { :users => :people } }
  let(:renamed) { described_class.new({ :people => 1}) }

  it { should eql(renamed) }
end
