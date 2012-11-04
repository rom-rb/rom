require 'spec_helper'

describe RelationRegistry::RelationNode::VeritasRelation, '#base?' do
  subject { object.base? }

  let(:object) { described_class.new(:users, relation) }

  context "with a base relation" do
    let(:relation) { Veritas::Relation::Base.new(:users, []) }

    it { should be(true) }
  end

  context "with a non-base relation" do
    let(:relation) { Veritas::Relation.new([], []) }

    it { should be(false) }
  end
end
