require 'spec_helper'

describe Finalizer::DependentRelationshipSet, '#target_keys' do
  subject { object.target_keys }

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

  it { should eql([ :song_id, :tag_id ]) }
end
