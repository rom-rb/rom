require 'spec_helper'

describe Relationship::ViaDefinition, '#via_source_key' do
  subject { object.via_source_key }

  let(:object)       { described_class.new(relationship, mapper_registry) }
  let(:relationship) { tags }

  let(:mapper_registry) {
    MapperRegistry.new << song_mapper << song_tag_mapper << tag_mapper
  }

  let(:song_mapper)     { mock_mapper(song_model, [], [ song_tags, tags ]) }
  let(:song_tag_mapper) { mock_mapper(song_tag_model, [], [ song, tag ]) }
  let(:tag_mapper)      { mock_mapper(tag_model) }

  let(:song_model)     { mock_model('Song') }
  let(:song_tag_model) { mock_model('SongTag') }
  let(:tag_model)      { mock_model('Tag') }

  let(:song_tags) { Relationship::OneToMany .new(:song_tags, song_model, song_tag_model) }
  let(:song)      { Relationship::ManyToOne .new(:song, song_tag_model, song_model) }
  let(:tag)       { Relationship::ManyToOne .new(:tag, song_tag_model, tag_model) }
  let(:tags)      { Relationship::ManyToMany.new(:tags, song_model, tag_model, :through => :song_tags, :via => via) }

  let(:via_source_key) { [ :tag_id ] }

  context 'when relationship.via is a Symbol' do
    let(:tags) { Relationship::ManyToMany.new(:tags, song_model, tag_model, :through => :song_tags, :via => via) }
    let(:via) { :tag }

    it { should eql(via_source_key) }
  end

  context 'when relationship.via is nil' do
    let(:via) { nil }

    it { should eql(via_source_key) }
  end
end
