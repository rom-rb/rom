require 'spec_helper'

describe RelationRegistry::Builder::NodeNameSet, '#to_a' do
  subject { object.to_a.map(&:to_sym) }

  let(:object)       { described_class.new(info_contents, registry) }
  let(:registry)     { { :song_tags => song_tags, :tags => tags, :infos => infos, :info_contents => info_contents } }

  let(:song_tags)     { OpenStruct.new(:name => :song_tags) }
  let(:tags)          { OpenStruct.new(:name => :tags, :via => :song_tags) }
  let(:infos)         { OpenStruct.new(:name => :infos, :via => :tags) }
  let(:info_contents) { OpenStruct.new(:name => :info_contents, :via => :infos) }

  it { should == [ :song_tags_X_tags, :song_tags_X_tags_X_infos, :song_tags_X_tags_X_infos_X_info_contents ] }
end
