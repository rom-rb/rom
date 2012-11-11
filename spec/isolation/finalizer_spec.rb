require 'spec_helper_integration'

describe 'Finalizer', :isolation => true do
  before(:all) do
    class Song
    end

    class Tag
    end

    class Info
    end

    class InfoContent
    end

    class SongTag
    end

    class TagMapper < DataMapper::Mapper::Relation
      model         Tag
      relation_name :tags
      repository    :postgres

      map :id,   Integer, :key => true
      map :name, String

      has 0..n, :song_tags, SongTag
      has 0..n, :songs,     Song, :through => :song_tags
    end

    class InfoMapper < DataMapper::Mapper::Relation
      model         Info
      relation_name :infos
      repository    :postgres

      map :id,     Integer, :key => true
      map :tag_id, Integer
      map :text,   String
    end

    class InfoContentMapper < DataMapper::Mapper::Relation
      model         InfoContent
      relation_name :info_contents
      repository    :postgres

      map :id,      Integer, :key => true
      map :info_id, Integer
      map :content, String
    end

    class SongTagMapper < DataMapper::Mapper::Relation
      model         SongTag
      relation_name :song_tags
      repository    :postgres

      map :song_id, Integer, :key => true
      map :tag_id,  Integer, :key => true
    end

    class SongMapper < DataMapper::Mapper::Relation
      model         Song
      relation_name :songs
      repository    :postgres

      map :id,    Integer, :key => true
      map :title, String

      has 0..n, :song_tags, SongTag
      has 0..n, :tags, Tag, :through => :song_tags

      has 1, :song_tag, SongTag
      has 1, :tag,      Tag, :through => :song_tag

      has 1, :good_tag, Tag, :through => :song_tag do
        restrict { |r| r.tag_name.eq('good') }
      end

      has 0..n, :infos, Info, :through => :tags, :target_key => :tag_id

      has 0..n, :info_contents, InfoContent, :through => :infos, :target_key => :info_id

      has 0..n, :good_info_contents, InfoContent, :through => :infos do
        restrict { |r| r.info_content_content.eq('really, really good') }
      end
    end
  end

  let(:relations) { SongMapper.relations }

  it 'finalizes songs relation' do
    relation = relations[:songs]

    relation.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    relation.aliases.to_hash.should eql(:id => :song_id, :title => :song_title)

    relation.should be_base
  end

  it 'finalizes tags relation' do
    relation = relations[:tags]

    relation.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    relation.aliases.to_hash.should eql(:id => :tag_id, :name => :tag_name)

    relation.should be_base
  end

  it 'finalizes song_tags relation' do
    relation = relations[:song_tags]

    relation.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    relation.aliases.to_hash.should eql({})

    relation.should be_base
  end

  it 'finalizes infos relation' do
    relation = relations[:infos]

    relation.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    relation.aliases.to_hash.should eql(:id => :info_id, :text => :info_text)

    relation.should be_base
  end

  it 'finalizes info_contents relation' do
    relation = relations[:info_contents]

    relation.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    relation.aliases.to_hash.should eql(:id => :info_content_id, :content => :info_content_content)

    relation.should be_base
  end

  it 'finalizes info_contents relation' do
    relation = relations[:info_contents]

    relation.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    relation.aliases.to_hash.should eql(:id => :info_content_id, :content => :info_content_content)

    relation.should be_base
  end

  it 'finalizes songs-have-many-tags-through-song_tags relation' do
    node = relations[:songs_X_song_tags_X_tags]

    node.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    node.should_not be_base

    edge = relations.edge_for(relations[:songs_X_song_tags], relations[:tags])

    edge.relation.relation.should eql(node.relation)
  end

  it 'finalizes songs-have-one-good_tag-through-song_tag relation' do
    node = relations[:songs_X_song_tags_X_good_tag]

    node.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    node.should_not be_base

    edge = relations.edge_for(relations[:songs_X_song_tags], relations[:tags])

    edge.relation.relation.should eql(node.relation)
  end

  it 'finalizes songs-have-many-infos-through-tags relation' do
    node = relations[:songs_X_song_tags_X_tags_X_infos]

    node.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    node.should_not be_base

    edge = relations.edge_for(relations[:songs_X_song_tags_X_tags], relations[:infos])

    edge.relation.relation.should eql(node.relation)
  end

  it 'finalizes songs-have-many-info_contents-through-infos relation' do
    node = relations[:songs_X_song_tags_X_tags_X_infos_X_info_contents]

    node.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    node.should_not be_base

    edge = relations.edge_for(relations[:songs_X_song_tags_X_tags_X_infos], relations[:info_contents])

    edge.relation.relation.should eql(node.relation)
  end

  it 'finalizes songs-have-many-good_info_contents-through-infos relation' do
    node = relations[:songs_X_song_tags_X_tags_X_infos_X_good_info_contents]

    node.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    node.should_not be_base

    edge = relations.edge_for(relations[:songs_X_song_tags_X_tags_X_infos], relations[:info_contents])

    edge.relation.relation.should eql(node.relation)
  end

  it 'finalizes tags-have-many-song_tags relation' do
    node = relations[:tags_X_song_tags]

    node.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    node.should_not be_base

    edge = relations.edge_for(relations[:tags], relations[:song_tags])

    edge.relation.relation.should eql(node.relation)
  end

  it 'finalizes tags-have-many-songs-through-song_tags relation' do
    node = relations[:tags_X_song_tags_X_songs]

    node.should be_instance_of(RelationRegistry::RelationNode::VeritasRelation)
    node.should_not be_base

    edge = relations.edge_for(relations[:tags_X_song_tags], relations[:songs])

    edge.relation.relation.should eql(node.relation)
  end

  it 'finalizes song mapper' do
    DataMapper[Song].relation.should be(relations[:songs])
  end

  it 'finalizes tag mapper' do
    DataMapper[Tag].relation.should be(relations[:tags])
  end

  it 'finalizes song_tag mapper' do
    DataMapper[SongTag].relation.should be(relations[:song_tags])
  end

  it 'finalizes info mapper' do
    DataMapper[Info].relation.should be(relations[:infos])
  end

  it 'finalizes info content mapper' do
    DataMapper[InfoContent].relation.should be(relations[:info_contents])
  end

  it 'finalizes song-song-tags mapper' do
    DataMapper[Song].include(:song_tags).relation.should be(relations[:songs_X_song_tags])
  end

  it 'finalizes song-song-tag mapper' do
    DataMapper[Song].include(:song_tag).relation.should be(relations[:songs_X_song_tags])
  end

  it 'finalizes song-tag-through-song_tag mapper' do
    DataMapper[Song].include(:tag).relation.should be(relations[:songs_X_song_tags_X_tags])
  end

  it 'finalizes song-tags mapper' do
    DataMapper[Song].include(:tags).relation.should be(relations[:songs_X_song_tags_X_tags])
  end

  it 'finalizes song-infos mapper' do
    DataMapper[Song].include(:infos).relation.should be(relations[:songs_X_song_tags_X_tags_X_infos])
  end

  it 'finalizes song-info-contents mapper' do
    DataMapper[Song].include(:info_contents).relation.should be(relations[:songs_X_song_tags_X_tags_X_infos_X_info_contents])
  end

  it 'finalizes song-good-info-contents mapper' do
    DataMapper[Song].include(:good_info_contents).relation.should be(relations[:songs_X_song_tags_X_tags_X_infos_X_good_info_contents])
  end
end
