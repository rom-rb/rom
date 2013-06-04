require 'spec_helper'

describe Relation::Header::RelationIndex, '#aliases' do
  subject { object.aliases(other) }

  let(:object) { described_class.new({ :users  => 1 }) }

  context "with no common relation names" do
    let(:other) { described_class.new({ :people => 1 }) }

    it { should eql({}) }
  end

  context "with common relation names" do
    context "and equal relation counts" do
      let(:other) { described_class.new({ :users => 1 }) }

      it { should eql({}) }
    end

    context "and different relation counts" do
      let(:other) { described_class.new({ :users => 2 }) }

      it { should eql({ :users => :users_2 }) }
    end
  end
end
