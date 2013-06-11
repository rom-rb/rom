require 'spec_helper'

describe Header::RelationIndex, '#join' do
  subject { object.join(other) }

  let(:object)  { described_class.new(entries) }
  let(:other)   { described_class.new(other_entries) }
  let(:entries) { { :users => 1 } }
  let(:joined)  { described_class.new(joined_entries) }

  shared_examples_for "#{described_class}#join" do
    it { should eql(joined) }
  end

  context "when performing a join with no common relations" do
    let(:other_entries)  { { :addresses => 1 } }
    let(:joined_entries) { { :users => 1, :addresses => 1 } }

    it_behaves_like "#{described_class}#join"
  end

  context "when performing a join with common relation names" do
    let(:other_entries)  { { :users => 1 } }
    let(:joined_entries) { { :users => 2 } }

    it_behaves_like "#{described_class}#join"
  end
end
