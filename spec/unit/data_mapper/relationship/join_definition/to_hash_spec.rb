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
      Mapper::Attribute::Alias.new(:id, :songs)    => Mapper::Attribute::Alias.new(:song_id, :song_tags),
      Mapper::Attribute::Alias.new(:title, :songs) => Mapper::Attribute::Alias.new(:tag_id, :song_tags)
    )
  end
end
