require 'spec_helper'

describe Relation::Graph::Connector::Builder, '.call' do
  subject { described_class.call(DM_ENV.relations, mapper_registry, relationship) }

  let(:mapper_registry) do
    mapper_registry = Mapper::Registry.new

    [ song_mapper, song_tag_mapper, tag_mapper, info_mapper ].each do |mapper|
      mapper_registry.register(mapper)
    end

    mapper_registry
  end

  let(:song_mapper)            { mock_mapper(song_model, song_attributes, song_relationships).new(songs_relation) }
  let(:song_model)             { mock_model('Song') }
  let(:songs_relation)         { mock_relation(:songs) }
  let(:song_attributes)        { [ songs_id, songs_title ] }
  let(:songs_id)               { mock_attribute(:id,    Integer, :key => true) }
  let(:songs_title)            { mock_attribute(:title, String) }
  let(:song_relationships)     { [ songs_song_tags_relationship, songs_tags_relationship, songs_infos_relationship ] }

  let(:song_tag_mapper)        { mock_mapper(song_tag_model, song_tag_attributes, song_tag_relationships).new(song_tags_relation) }
  let(:song_tag_model)         { mock_model('SongTag') }
  let(:song_tags_relation)     { mock_relation(:song_tags) }
  let(:song_tag_attributes)    { [ song_tags_song_id, song_tags_tag_id ] }
  let(:song_tags_song_id)      { mock_attribute(:song_id, Integer, :key => true) }
  let(:song_tags_tag_id)       { mock_attribute(:tag_id,  Integer, :key => true) }
  let(:song_tag_relationships) { [ song_tags_song_relationship, song_tags_tag_relationship ] }

  let(:tag_mapper)             { mock_mapper(tag_model, tag_attributes, tag_relationships).new(tags_relation) }
  let(:tag_model)              { mock_model('Tag') }
  let(:tags_relation)          { mock_relation(:tags) }
  let(:tag_attributes)         { [ tags_id, tags_name ] }
  let(:tags_id)                { mock_attribute(:id,   Integer, :key => true) }
  let(:tags_name)              { mock_attribute(:name, String) }
  let(:tag_relationships)      { [ tags_infos_relationship ] }

  let(:info_mapper)            { mock_mapper(info_model, info_attributes, info_relationships).new(infos_relation) }
  let(:info_model)             { mock_model('Info') }
  let(:infos_relation)         { mock_relation(:infos) }
  let(:info_attributes)        { [ infos_id, infos_text ] }
  let(:infos_id)               { mock_attribute(:id,   Integer, :key => true) }
  let(:infos_text)             { mock_attribute(:text, String) }
  let(:info_relationships)     { [] }

  let(:songs_song_tags_relationship) { Relationship::OneToMany. new(:song_tags, song_model,     song_tag_model) }
  let(:song_tags_song_relationship)  { Relationship::ManyToOne. new(:song,      song_tag_model, song_model) }
  let(:song_tags_tag_relationship)   { Relationship::ManyToOne. new(:tag,       song_tag_model, tag_model) }
  let(:songs_tags_relationship)      { Relationship::ManyToMany.new(:tags,      song_model,     tag_model,  :through => :song_tags, :via => :tag) }
  let(:songs_infos_relationship)     { Relationship::ManyToMany.new(:infos,     song_model,     info_model, :through => :tags,      :via => :infos) }
  let(:tags_infos_relationship)      { Relationship::OneToMany. new(:infos,     tag_model,      info_model) }

  before do
    mapper_registry.each do |_, mapper|
      name     = mapper.relation_name
      relation = mapper.class.gateway_relation
      header   = Relation::Graph::Node.header(name, mapper.attributes.fields)

      DM_ENV.relations.new_node(name, relation, header)

      mapper.relationships.each do |relationship|
        relationship.finalize(mapper_registry)
      end
    end

    subject
  end

  let(:relations) { DM_ENV.relations }

  context "with one-to-many" do
    let(:relationship)   { songs_song_tags_relationship }
    let(:name)           { :songs_X_song_tags }
    let(:connector_name) { :"#{name}__song_tags" }

    it "adds songs_X_song_tags relation node" do
      node = relations[name]
      node.should be_instance_of(Relation::Graph::Node)
    end

    it "adds song_tags relation edge" do
      edge = relations.edge_for(name)
      edge.should be_instance_of(Relation::Graph::Edge)
    end

    it "adds songs_X_song_tags connector" do
      node      = relations.node_for(relations[name])
      connector = relations.connectors[connector_name]
      connector.node.should eql(node)
    end
  end

  context "with one-to-many via other" do
    let(:relationship)   { songs_tags_relationship }
    let(:name)           { :songs_X_song_tags_X_tags }
    let(:connector_name) { :"#{name}__tags" }

    it "adds songs_X_song_tags_X_tags relation node" do
      node = relations[:songs_X_song_tags]
      node.should be_instance_of(Relation::Graph::Node)
      node = relations[name]
      node.should be_instance_of(Relation::Graph::Node)
    end

    it "adds tags relation edge" do
      edge = relations.edge_for(name)
      edge.should be_instance_of(Relation::Graph::Edge)
    end

    it "adds songs_X_song_tags_X_tags connector" do
      node      = relations.node_for(relations[name])
      connector = relations.connectors[connector_name]
      connector.node.should eql(node)
    end
  end

  context "with one-to-many via other via another" do
    let(:relationship)   { songs_infos_relationship }
    let(:name)           { :songs_X_song_tags_X_tags_X_infos }
    let(:connector_name) { :"#{name}__infos" }

    it "adds songs_X_song_tags_X_tags_X_infos relation node" do
      node = relations[:songs_X_song_tags]
      node.should be_instance_of(Relation::Graph::Node)
      node = relations[:songs_X_song_tags_X_tags]
      node.should be_instance_of(Relation::Graph::Node)
      node = relations[name]
      node.should be_instance_of(Relation::Graph::Node)
    end

    it "adds infos relation edge" do
      edge = relations.edge_for(name)
      edge.should be_instance_of(Relation::Graph::Edge)
    end

    it "adds songs_X_song_tags_X_tags_X_infos connector" do
      node      = relations.node_for(relations[name])
      connector = relations.connectors[connector_name]
      connector.node.should eql(node)
    end
  end
end
