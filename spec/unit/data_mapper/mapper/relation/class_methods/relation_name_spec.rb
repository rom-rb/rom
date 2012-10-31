require 'spec_helper'

describe Mapper::Relation, '.relation_name' do
  let(:name) { :users }

  context "with a name" do
    it "sets the relation name" do
      described_class.relation_name(name)
      described_class.relation_name.should be(name)
    end
  end
end
