require 'spec_helper'

describe RelationRegistry::Connector, '#aliased_for' do
  subject { object.aliased_for(via_relationship) }

  let(:object) { described_class.new(edge, relationship) }

  let(:songs)      { mock_relation(:songs, [[:id, Integer], [:title, String]]) }
  let(:song_tags)  { mock_relation(:song_tags, [[:id, Integer], [:song_id, Integer], [:tag_id, Integer]]) }

  let(:song_tags_aliases) { mock_alias_set(:song_tag, :tag_id => Integer) }

  let(:songs_node)     { TEST_ENGINE.relation_node_class.new(songs.name, songs) }
  let(:song_tags_node) { TEST_ENGINE.relation_node_class.new(song_tags.name, song_tags, song_tags_aliases) }
  let(:edge)           { TEST_ENGINE.relation_edge_class.new(:song_song_tags, songs_node, song_tags_node) }

  let(:relationship)     { mock_relationship(:song_tags, :source_key => :id, :target_key => :song_id) }
  let(:via_relationship) { mock_relationship(:tags,      :source_key => :id, :target_key => :tag_id) }

  it { should be_kind_of(described_class) }

  it "sets aliases for via relationship" do
    subject.target_aliases.to_hash.should eql({})
  end
end
