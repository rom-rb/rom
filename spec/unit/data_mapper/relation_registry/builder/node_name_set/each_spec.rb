require 'spec_helper'

describe RelationRegistry::Builder::NodeNameSet, '#each' do
  subject { object.each }

  let(:object) { described_class.new(info_contents, mapper_registry) }

  let(:mapper_registry) {
    MapperRegistry.new << song_mapper << song_tag_mapper << tag_mapper << info_mapper << info_content_mapper
  }

  let(:song_mapper)         { mock_mapper(song_model, [], [ song_tags, tags, funky_infos, info_contents ]) }
  let(:song_tag_mapper)     { mock_mapper(song_tag_model) }
  let(:tag_mapper)          { mock_mapper(tag_model) }
  let(:info_mapper)         { mock_mapper(info_model) }
  let(:info_content_mapper) { mock_mapper(info_content_model) }

  let(:song_model)          { mock_model('Song') }
  let(:song_tag_model)      { mock_model('SongTag') }
  let(:tag_model)           { mock_model('Tag') }
  let(:info_model)          { mock_model('Info') }
  let(:info_content_model)  { mock_model('InfoContent') }

  let(:song_tags)     { Relationship::OneToMany .new(:song_tags,     song_model, song_tag_model) }
  let(:tags)          { Relationship::ManyToMany.new(:tags,          song_model, tag_model,          :through => :song_tags) }
  let(:funky_infos)   { Relationship::ManyToMany.new(:funky_infos,   song_model, info_model,         :through => :tags, :operation => Proc.new {}) }
  let(:info_contents) { Relationship::ManyToMany.new(:info_contents, song_model, info_content_model, :through => :funky_infos) }

  it { should be_instance_of(Enumerator) }
end
