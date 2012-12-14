require 'spec_helper'

describe Relationship::JoinDefinition, '#to_hash' do
  subject { object.to_hash }

  let(:object) { described_class.new(left, right) }

  let(:left)           { described_class::Side.new(left_relation, left_keys) }
  let(:left_relation)  { mock('left', :name => :songs) }
  let(:left_keys)      { [ :id, :title ] }

  let(:right)          { described_class::Side.new(right_relation, right_keys) }
  let(:right_relation) { mock('right', :name => :song_tags) }
  let(:right_keys)     { [ :song_id, :tag_id ] }

  it "should alias both left and right keys" do
    subject.should eql(
      :id => :song_id,
      :title => :tag_id
    )
  end
end
