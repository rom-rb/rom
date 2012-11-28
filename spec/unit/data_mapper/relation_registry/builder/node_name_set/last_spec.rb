require 'spec_helper'

describe RelationRegistry::Builder::NodeNameSet, '#last' do
  subject { object.last.to_sym }

  let(:object) { described_class.new(songs_info_contents, mapper_registry) }

  let(:mapper_registry) {
    MapperRegistry.new << song_mapper << song_tag_mapper << tag_mapper << info_mapper << info_content_mapper
  }

  let(:song_mapper)                { mock_mapper(song_model, [], song_relationships) }
  let(:song_relationships)         { [ songs_song_tags, songs_tags, songs_infos, songs_info_contents ] }

  let(:song_tag_mapper)            { mock_mapper(song_tag_model, [], song_tag_relationships) }
  let(:song_tag_relationships)     { [ song_tags_song, song_tags_tag ] }

  let(:tag_mapper)                 { mock_mapper(tag_model, [], tag_relationships) }
  let(:tag_relationships)          { [ tags_infos ] }

  let(:info_mapper)                { mock_mapper(info_model, [], info_relationships) }
  let(:info_relationships)         { [ infos_info_contents ] }

  let(:info_content_mapper)        { mock_mapper(info_content_model, [], info_content_relationships) }
  let(:info_content_relationships) { [] }

  let(:song_model)          { mock_model('Song') }
  let(:song_tag_model)      { mock_model('SongTag') }
  let(:tag_model)           { mock_model('Tag') }
  let(:info_model)          { mock_model('Info') }
  let(:info_content_model)  { mock_model('InfoContent') }

  let(:songs_song_tags)     { Relationship::OneToMany .new(:song_tags,     song_model,     song_tag_model) }
  let(:songs_tags)          { Relationship::ManyToMany.new(:tags,          song_model,     tag_model,          :through => :song_tags, :via => :tag) }
  let(:songs_infos)         { Relationship::ManyToMany.new(:infos,         song_model,     info_model,         :through => :tags,      :via => :infos) }
  let(:songs_info_contents) { Relationship::ManyToMany.new(:info_contents, song_model,     info_content_model, :through => :infos,     :via => :info_contents) }
  let(:song_tags_song)      { Relationship::ManyToOne .new(:song,          song_tag_model, song_model) }
  let(:song_tags_tag)       { Relationship::ManyToOne .new(:tag,           song_tag_model, song_model) }
  let(:tags_infos)          { Relationship::OneToMany .new(:infos,         tag_model,      info_model) }
  let(:infos_info_contents) { Relationship::OneToMany .new(:info_contents, info_model,     info_content_model) }

  before do
    mapper_registry.each do |_, mapper|
      mapper.relationships.each { |relationship| relationship.finalize(mapper_registry) }
    end
  end

  it { should be(:songs_X_song_tags_X_tags_X_infos_X_info_contents) }
end
