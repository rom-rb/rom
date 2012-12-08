require 'spec_helper'

describe Relation::Mapper::Builder, '#mapper' do
  subject { object.mapper }

  let(:object) { described_class.new(connector) }

  let(:mapper_registry) do
    mapper_registry = DM_ENV.registry

    [ song_mapper, song_tag_mapper, tag_mapper ].each do |mapper|
      mapper_registry.register(mapper)
    end

    mapper_registry
  end

  let(:relations) { song_mapper.relations }

  let(:song_mapper)            { mock_mapper(song_model, song_attributes, song_relationships).new(songs_relation) }
  let(:song_model)             { mock_model('Song') }
  let(:songs_relation)         { mock_relation(:songs) }
  let(:song_attributes)        { [ songs_id, songs_title ] }
  let(:songs_id)               { mock_attribute(:id,    Integer, :key => true) }
  let(:songs_title)            { mock_attribute(:title, String) }
  let(:song_relationships)     { [ songs_song_tags_relationship, songs_tags_relationship ] }

  let(:song_tag_mapper)        { mock_mapper(song_tag_model, song_tag_attributes, song_tag_relationships).new(song_tags_relation) }
  let(:song_tag_model)         { mock_model('SongTag') }
  let(:song_tags_relation)     { mock_relation(:song_tags) }
  let(:song_tag_attributes)    { [ song_tags_song_id, song_tags_tag_id ] }
  let(:song_tags_song_id)      { mock_attribute(:song_id, Integer, :key => true) }
  let(:song_tags_tag_id)       { mock_attribute(:tag_id,  Integer, :key => true) }
  let(:song_tag_relationships) { [ song_tags_song_relationship, song_tags_tag_relationship ] }

  let(:tag_mapper)             { mock_mapper(tag_model, tag_attributes, []).new(tags_relation) }
  let(:tag_model)              { mock_model('Tag') }
  let(:tags_relation)          { mock_relation(:tags) }
  let(:tag_attributes)         { [ tags_id, tags_name ] }
  let(:tags_id)                { mock_attribute(:id,   Integer, :key => true) }
  let(:tags_name)              { mock_attribute(:name, String) }

  let(:songs_song_tags_relationship) { Relationship::OneToMany. new(:song_tags, song_model,     song_tag_model) }
  let(:song_tags_song_relationship)  { Relationship::ManyToOne. new(:song,      song_tag_model, song_model) }
  let(:song_tags_tag_relationship)   { Relationship::ManyToOne. new(:tag,       song_tag_model, tag_model) }
  let(:songs_tags_relationship)      { Relationship::ManyToMany.new(:tags,      song_model,     tag_model,  :through => :song_tags) }

  before do
    mapper_registry.each do |_, mapper|
      name     = mapper.relation_name
      relation = mapper.class.gateway_relation
      aliases  = mapper.relations.aliases(name, mapper.attributes)

      mapper.relations.new_node(name, relation, aliases)
    end

    mapper_registry.each do |_, mapper|
      mapper.relationships.each do |relationship|
        relationship.finalize(mapper_registry)
      end
    end

    mapper_registry.each do |_, mapper|
      mapper.relationships.each do |relationship|
        Relation::Graph::Connector::Builder.call(mapper.relations, mapper_registry, relationship)
      end
    end

    subject
  end

  context "when connector is not via other" do

    let(:connector) { relations.connectors[:songs_X_song_tags__song_tags] }

    it { should be_kind_of(Relation::Mapper) }

    it "remaps source model attributes" do
      subject.attributes[:id].field.should eql(:song_tags_song_id)
      subject.attributes[:title].field.should eql(:songs_title)
    end

    it "sets embedded collection attribute" do
      user_orders = subject.attributes[:song_tags]

      user_orders.should be_instance_of(Mapper::Attribute::EmbeddedCollection)
    end

    it "remaps target model attributes" do
      target_mapper = subject.attributes[:song_tags].mapper

      target_mapper.attributes[:song_id].field.should eql(:song_tags_song_id)
      target_mapper.attributes[:tag_id].field.should eql(:song_tags_tag_id)
    end

    it "extends the mapper with OneToMany iterator" do
      subject.should be_kind_of(Relationship::OneToMany::Iterator)
    end
  end

  context "when connector is via other" do
    let(:connector) { relations.connectors[:songs_X_song_tags_X_tags__tags] }

    it { should be_kind_of(Relation::Mapper) }

    it "remaps target model attributes using connector aliases" do
      target_mapper = subject.attributes[:tags].mapper

      target_mapper.attributes[:id].field.should eql(:tags_id)
      target_mapper.attributes[:name].field.should eql(:tags_name)
    end
  end
end
