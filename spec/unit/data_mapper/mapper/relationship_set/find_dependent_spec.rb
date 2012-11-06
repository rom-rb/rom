require 'spec_helper'

describe DataMapper::Mapper::RelationshipSet, '#find_dependent' do
  subject { object.find_dependent(relationships) }

  let(:object)         { described_class.new }
  let(:songs)          { mock('songs',     :name => :songs,     :target_model => song_model,     :via => nil) }
  let(:song_tags)      { mock('song_tags', :name => :song_tags, :target_model => song_tag_model, :via => nil) }
  let(:tags)           { mock('tags',      :name => :tags,      :target_model => tag_model,      :via => :song_tags) }
  let(:song_model)     { mock_model(:Song) }
  let(:song_tag_model) { mock_model(:SongTag) }
  let(:tag_model)      { mock_model(:Tag) }

  let(:relationships)  { [ song_tags ] }

  before { object << songs << song_tags << tags }

  it { should have(1).items }
  it { should include(tags) }
end
