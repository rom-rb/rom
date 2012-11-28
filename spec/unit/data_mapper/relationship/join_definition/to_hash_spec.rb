require 'spec_helper'

describe Relationship::JoinDefinition, '#to_hash' do
  subject { object.to_hash }

  let(:object)     { described_class.new(left, right) }

  let(:left)       { described_class::Side.new(left_name, left_keys) }
  let(:left_name)  { :songs }
  let(:left_keys)  { [ :id, :title ] }

  let(:right)      { described_class::Side.new(right_name, right_keys) }
  let(:right_name) { :song_tags }
  let(:right_keys) { [ :song_id, :tag_id ] }

  it "should alias both left and right keys" do
    subject.should eql({
      :songs_id    => :song_tags_song_id,
      :songs_title => :song_tags_tag_id
    })
  end
end
