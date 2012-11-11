require 'spec_helper'

describe RelationRegistry::Builder::NodeNameSet, '#to_a' do
  subject { described_class.new(info_contents, registry, relations).to_a }

  let(:registry)  { { :song_tags => song_tags, :tags => tags, :infos => infos, :info_contents => info_contents } }
  let(:relations) { { song_model => :songs, song_tag_model => :song_tags, tag_model => :tags, info_model => :infos, info_content_model => :info_contents } }

  let(:song_model)         { mock_model('Song') }
  let(:song_tag_model)     { mock_model('SongTag') }
  let(:tag_model)          { mock_model('Tag') }
  let(:info_model)         { mock_model('Info') }
  let(:info_content_model) { mock_model('InfoContent') }

  let(:song_tags)     { OpenStruct.new(:name => :song_tags,     :source_model => song_model, :target_model => song_tag_model) }
  let(:tags)          { OpenStruct.new(:name => :tags,          :source_model => song_model, :target_model => tag_model,          :through => :song_tags) }
  let(:infos)         { OpenStruct.new(:name => :funky_infos,   :source_model => song_model, :target_model => info_model,         :through => :tags, :operation => Proc.new {}) }
  let(:info_contents) { OpenStruct.new(:name => :info_contents, :source_model => song_model, :target_model => info_content_model, :through => :infos) }

  it do
    subject.map(&:to_sym).should == [ :songs_X_song_tags, :songs_X_song_tags_X_tags,
                :songs_X_song_tags_X_tags_X_funky_infos,
                :songs_X_song_tags_X_tags_X_funky_infos_X_info_contents ]
  end
end
