require 'spec_helper'

describe Finalizer::DependentRelationshipSet, '#each' do
  let(:object)         { described_class.new(song_tag_model, mappers) }

  let(:song_model)     { mock_model(:Song) }
  let(:song_tag_model) { mock_model(:SongTag) }
  let(:tag_model)      { mock_model(:Tag) }

  let(:song_mapper)     { mock_mapper(song_model) }
  let(:song_tag_mapper) { mock_mapper(song_tag_model) }
  let(:tag_mapper)      { mock_mapper(tag_model) }


  let(:songs_song_tags) { Relationship::Builder::Has.build(song_mapper, 0..Infinity, :song_tags, song_tag_model) }
  let(:tags_song_tags)  { Relationship::Builder::Has.build(tag_mapper,  0..Infinity, :song_tags, song_tag_model) }
  let(:tags_songs)      { Relationship::Builder::Has.build(tag_mapper,  0..Infinity, :songs,     song_model, :through => :song_tags) }
  let(:songs_tags)      { Relationship::Builder::Has.build(song_mapper, 0..Infinity, :tags,      tag_model,  :through => :song_tags) }

  let(:mappers) { [ song_mapper, song_tag_mapper, tag_mapper ] }

  before do
    song_mapper.relationships << songs_song_tags << songs_tags
    tag_mapper.relationships  << tags_song_tags  << tags_songs
  end

  context "with a block" do
    it "iterates over dependent relationships" do
      songs_song_tags.should_receive(:inspect).once()
      tags_song_tags.should_receive(:inspect).once()
      songs_tags.should_receive(:inspect).once()
      tags_songs.should_receive(:inspect).once()

      object.each { |relationship| relationship.inspect }
    end
  end

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
