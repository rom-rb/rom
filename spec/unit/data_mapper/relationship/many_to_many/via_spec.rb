require 'spec_helper'

describe Relationship::ManyToMany, '#via' do
  subject { object.via }

  let(:object) { tags }

  let(:mapper_registry) {
    Mapper::Registry.new << song_mapper << song_tag_mapper << tag_mapper
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

  before { object.finalize(mapper_registry) }

  context 'when :via is not present in options' do
    let(:via) { nil }

    it { should be(:tag) }
  end

  context 'when :via is present in options' do
    let(:via) { :tag }

    it { should be(via) }
  end
end
