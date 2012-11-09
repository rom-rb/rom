require 'spec_helper'

describe RelationRegistry::Builder::NodeNameSet, '#to_a' do
  subject { described_class.new(info_contents, registry, relations).each }

  let(:registry)  { { :song_tags => song_tags, :tags => tags, :infos => infos, :info_contents => info_contents } }
  let(:relations) { { song_tag_model => :song_tags, tag_model => :tags, info_model => :infos, info_content_model => :info_contents } }

  let(:song_tag_model)     { mock_model('SongTag') }
  let(:tag_model)          { mock_model('Tag') }
  let(:info_model)         { mock_model('Info') }
  let(:info_content_model) { mock_model('InfoContent') }

  let(:song_tags)     { OpenStruct.new(:name => :song_tags,     :target_model => song_tag_model) }
  let(:tags)          { OpenStruct.new(:name => :tags,          :target_model => tag_model,          :through => :song_tags) }
  let(:infos)         { OpenStruct.new(:name => :funky_infos,   :target_model => info_model,         :through => :tags) }
  let(:info_contents) { OpenStruct.new(:name => :info_contents, :target_model => info_content_model, :through => :infos) }

  it { should be_instance_of(Enumerator) }
end
