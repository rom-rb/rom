require 'spec_helper'

describe RelationRegistry::RelationConnector, '#for_relationship' do
  subject { object.for_relationship(via_relationship) }

  let(:object) { described_class.new(relationship, songs_node, song_tags_node) }

  let(:songs)      { mock_relation(:songs, [[:id, Integer], [:title, String]]) }
  let(:song_tags)  { mock_relation(:song_tags, [[:id, Integer], [:song_id, Integer], [:tag_id, Integer]]) }

  let(:song_tags_aliases) { mock_alias_set(:song_tag, :tag_id => Integer) }

  let(:songs_node)     { RelationRegistry::RelationNode.new(songs.name, songs) }
  let(:song_tags_node) { RelationRegistry::RelationNode.new(song_tags.name, song_tags, song_tags_aliases) }

  let(:relationship)     { mock_relationship(:song_tags, :source_key => :id, :target_key => :song_id) }
  let(:via_relationship) { mock_relationship(:tags,      :source_key => :id, :target_key => :tag_id) }

  it { should be_kind_of(described_class) }

  it "sets aliases for via relationship" do
    subject.target_aliases.to_hash.should eql({})
  end
end
