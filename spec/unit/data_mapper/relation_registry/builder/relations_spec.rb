require 'spec_helper'

describe RelationRegistry::Builder, '#relations' do
  subject { described_class.call(relations, mappers, relationship) }

  let(:songs_relation) { mock_relation(:songs) }
  let(:song_model)     { mock_model('Song') }
  let(:song_mapper)    { mock_mapper(song_model).new(songs_relation) }

  let(:song_tags_relation) { mock_relation(:song_tags) }
  let(:song_tag_model)     { mock_model('SongTag') }
  let(:song_tag_mapper)    { mock_mapper(song_tag_model).new(song_tags_relation) }

  let(:tags_relation) { mock_relation(:super_tags) }
  let(:tag_model)     { mock_model('Tag') }
  let(:tag_mapper)    { mock_mapper(tag_model).new(tags_relation) }

  let(:infos_relation) { mock_relation(:infos) }
  let(:info_model)     { mock_model('Info') }
  let(:info_mapper)    { mock_mapper(info_model).new(infos_relation) }

  let(:mappers) do
    mapper_registry = MapperRegistry.new

    [ song_mapper, song_tag_mapper, tag_mapper, info_mapper ].each do |mapper|
      mapper_registry.register(mapper)
    end

    mapper_registry
  end

  let(:song_tags_relationship) {
    mock_relationship(
      :song_tags,
      :source_model => song_model,
      :target_model => song_tag_model,
      :through      => nil
    )
  }

  let(:tags_relationship) {
    mock_relationship(
      :super_tags,
      :source_model => song_model,
      :target_model => tag_model,
      :through      => :song_tags,
      :operation    => Proc.new { self }
    )
  }

  let(:infos_relationship) {
    mock_relationship(
      :infos,
      :source_model => song_model,
      :target_model => info_model,
      :through      => :super_tags
    )
  }

  let!(:relations) { RelationRegistry.new(TEST_ENGINE) }

  before { relations << songs_relation << song_tags_relation << tags_relation << infos_relation }

  context "with one-to-many" do
    let(:relationship) { song_tags_relationship }

    before do
      song_mapper.stub!(:relationships).and_return(:song_tags => song_tags_relationship)
      subject
    end

    it "adds songs_X_song_tags relation node" do
      relations[:songs_X_song_tags].should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    end

    it "adds song_tags relation edge" do
      relations.edge_for(relations[:songs], relations[:song_tags]).should be_instance_of(RelationRegistry::RelationEdge)
    end
  end

  context "with one-to-many via other" do
    let(:relationship) { tags_relationship }

    before do
      song_mapper.stub!(:relationships).and_return(
        :song_tags  => song_tags_relationship,
        :super_tags => tags_relationship)
      subject
    end

    it "adds songs_X_song_tags_X_tags relation node" do
      relations[:songs_X_song_tags_X_super_tags].should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    end

    it "adds super_tags relation edge" do
      relations.edge_for(relations[:songs_X_song_tags], relations[:super_tags]).should be_instance_of(RelationRegistry::RelationEdge)
    end
  end

  context "with one-to-many via other via another" do
    let(:relationship) { infos_relationship }

    before do
      song_mapper.stub!(:relationships).and_return(
        :song_tags  => song_tags_relationship,
        :super_tags => tags_relationship,
        :infos      => infos_relationship
      )
      subject
    end

    it "adds songs_X_song_tags_X_super_tags_X_infos relation node" do
      relations[:songs_X_song_tags_X_super_tags_X_infos].should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    end

    it "adds infos relation edge" do
      relations.edge_for(relations[:songs_X_song_tags_X_super_tags], relations[:infos]).should be_instance_of(RelationRegistry::RelationEdge)
    end
  end
end
