require 'spec_helper_integration'

describe 'Using relation registry to generate joins' do
  before do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 2, 1
    insert_song_tag 2, 1, 2
  end

  let(:adapter) { DataMapper.adapters[:postgres] }

  let(:song_relation) do
    Veritas::Relation::Gateway.new(adapter,
      Veritas::Relation::Base.new(:songs, [[:id, Integer], [:title, String]])
    )
  end

  let(:tag_relation) do
    Veritas::Relation::Gateway.new(adapter,
      Veritas::Relation::Base.new(:tags, [[:id, Integer], [:name, String]])
    )
  end

  let(:song_tag_relation) do
    Veritas::Relation::Gateway.new(adapter,
      Veritas::Relation::Base.new(:song_tags, [[:song_id, Integer], [:tag_id, Integer]])
    )
  end

  it 'works' do
    registry = DataMapper::RelationRegistry.new

    song_attributes     = Mapper::AttributeSet.new << Mapper::Attribute.new(:id,      :type => Integer, :key => true) << Mapper::Attribute.new(:title,  :type => String)
    tag_attributes      = Mapper::AttributeSet.new << Mapper::Attribute.new(:id,      :type => Integer, :key => true) << Mapper::Attribute.new(:name,   :type => String)
    song_tag_attributes = Mapper::AttributeSet.new << Mapper::Attribute.new(:song_id, :type => Integer, :key => true) << Mapper::Attribute.new(:tag_id, :type => Integer, :key => true)

    song_aliases     = AliasSet.new(:song,     song_attributes)
    tag_aliases      = AliasSet.new(:tag,      tag_attributes)
    song_tag_aliases = AliasSet.new(:song_tag, song_tag_attributes)

    song_node     = RelationRegistry::RelationNode.new(:song,      song_relation,     song_aliases)
    tag_node      = RelationRegistry::RelationNode.new(:tags,      tag_relation,      tag_aliases)
    song_tag_node = RelationRegistry::RelationNode.new(:song_tags, song_tag_relation, song_tag_aliases)

    registry.add_node(song_node).add_node(tag_node).add_node(song_tag_node)

    song_song_tags_relationship = OpenStruct.new(:name => :song_song_tags, :source_key => :id, :target_key => :song_id)

    registry.new_edge(song_song_tags_relationship, song_node, song_tag_node)

    song_song_tags_relation = registry.edges.detect { |e| e.name == :song_song_tags }.relation

    song_song_tags_node = RelationRegistry::RelationNode.new(:song_song_tags, song_song_tags_relation)
    registry.add_node(song_song_tags_node)

    song_song_tags_relation.to_a

    song_tags_relationship = OpenStruct.new(:name => :song_tags, :source_key => :id, :target_key => :tag_id, :through => :song_song_tags)

    registry.new_edge(song_tags_relationship, tag_node, song_song_tags_node)

    song_tags_relation = registry.edges.detect { |e| e.name == :song_tags }.relation

    song_tags_relation.to_a
  end
end
