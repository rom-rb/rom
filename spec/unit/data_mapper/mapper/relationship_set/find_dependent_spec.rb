require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#find_dependent' do
  subject { object.find_dependent(song_tag_model) }

  let(:object)         { described_class.new }
  let(:songs)          { mock('songs',     :name => :songs,     :target_model => song_model,     :through => nil) }
  let(:song_tags)      { mock('song_tags', :name => :song_tags, :target_model => song_tag_model, :through => nil) }
  let(:tags)           { mock('tags',      :name => :tags,      :target_model => tag_model,      :through => :song_tags) }
  let(:song_model)     { mock_model(:Song) }
  let(:song_tag_model) { mock_model(:SongTag) }
  let(:tag_model)      { mock_model(:Tag) }

  before { object << songs << song_tags << tags }

  it { should be_instance_of(described_class) }
  it { should include(song_tags) }
  it { should include(tags) }
  it { should have(2).items }
end
