require 'spec_helper'

describe RelationRegistry::Connector::Builder, '.call', :type => :unit do
  let(:songs_relation) { mock_relation(:songs) }
  let(:song_model)     { mock_model('Song') }
  let(:song_mapper)    { mock_mapper(song_model).new(songs_relation) }

  let(:song_tags_relation) { mock_relation(:song_tags) }
  let(:song_tag_model)     { mock_model('SongTag') }
  let(:song_tag_mapper)    { mock_mapper(song_tag_model).new(song_tags_relation) }

  let(:tags_relation) { mock_relation(:tags) }
  let(:tag_model)     { mock_model('Tag') }
  let(:tag_mapper)    { mock_mapper(tag_model).new(tags_relation) }

  let(:mappers) { { song_model => song_mapper, song_tag_model => song_tag_mapper, tag_model => tag_mapper } }

  let(:song_tags_relationship) {
    mock_relationship(
      :song_tags,
      :source_model => song_model,
      :target_model => song_tag_model,
      :via          => nil
    )
  }

  let(:tags_relationship) {
    mock_relationship(
      :tags,
      :source_model => song_model,
      :target_model => tag_model,
      :via          => :song_tags
    )
  }

  let!(:registry)  { RelationRegistry.new }
  let!(:relations) { registry << songs_relation << song_tags_relation << tags_relation }

  context "with one-to-many" do
    subject { described_class.call(mappers, relations, song_tags_relationship) }

    it { should be_kind_of(RelationRegistry::Connector) }

    it "sets connector name" do
      subject.name.should be(:song_tags)
    end

    it "connects left side relation" do
      subject.source_node.relation.should be(songs_relation)
    end

    it "connects right side relation" do
      subject.target_node.relation.should be(song_tags_relation)
    end
  end

  context "with many-to-many via other" do
    subject { described_class.call(mappers, relations, tags_relationship) }

    let(:via_node) {
      registry[:songs_song_tags]
    }

    let(:tags_node) {
      registry[:tags_song_tags]
    }

    before do
      song_mapper.stub!(:relationships).and_return(:song_tags => song_tags_relationship)
      described_class.call(mappers, relations, song_tags_relationship)
    end

    it { should be_kind_of(RelationRegistry::Connector) }

    it "sets connector name" do
      subject.name.should be(:tags)
    end

    it "connects left side relation" do
      subject.source_node.relation.should be(via_node.relation)
    end

    it "connects right side relation" do
      subject.target_node.relation.should be(tags_node.relation)
    end
  end
end
