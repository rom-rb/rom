require 'spec_helper_integration'

describe 'Finalizer', :isolation => true do
  def env() DM_ENV end

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

    env.build(Tag, DM_ADAPTER) do
      model         Tag
      relation_name :tags

      map :id,   Integer, :key => true
      map :name, String

      has 0..n, :song_tags, SongTag
      has 0..n, :songs,     Song, :through => :song_tags
      has 0..n, :infos,     Info
    end

    env.build(Info, DM_ADAPTER) do
      model         Info
      relation_name :infos

      map :id,     Integer, :key => true
      map :tag_id, Integer
      map :text,   String

      belongs_to :tag, Tag

      has 0..n, :info_contents, InfoContent
    end

    env.build(InfoContent, DM_ADAPTER) do
      model         InfoContent
      relation_name :info_contents

      map :id,      Integer, :key => true
      map :info_id, Integer
      map :content, String

      belongs_to :info, Info
    end

    env.build(SongTag, DM_ADAPTER) do
      model         SongTag
      relation_name :song_tags

      map :song_id, Integer, :key => true
      map :tag_id,  Integer, :key => true

      belongs_to :song, Song
      belongs_to :tag,  Tag
    end

    env.build(Song, DM_ADAPTER) do
      model         Song
      relation_name :songs

      map :id,    Integer, :key => true
      map :title, String

      has 0..n, :song_tags, SongTag
      has 0..n, :tags, Tag, :through => :song_tags

      has 1, :song_tag, SongTag
      has 1, :tag,      Tag, :through => :song_tag

      has 1, :good_tag, Tag, :through => :song_tag, :via => :tag do
        restrict { |r| r.name.eq('good') }
      end

      has 0..n, :infos, Info, :through => :tags

      has 0..n, :info_contents, InfoContent, :through => :infos

      has 0..n, :good_info_contents, InfoContent, :through => :infos, :via => :info_contents do
        restrict { |r| r.content.eq('really, really good') }
      end
    end

    env.finalize
  end

  let(:relations) { env.relations }

  it 'finalizes songs relation' do
    relation = relations[:songs]
    relation.should be_instance_of(Relation::Graph::Node)
  end

  it 'finalizes tags relation' do
    relation = relations[:tags]
    relation.should be_instance_of(Relation::Graph::Node)
  end

  it 'finalizes song_tags relation' do
    relation = relations[:song_tags]
    relation.should be_instance_of(Relation::Graph::Node)
  end

  it 'finalizes infos relation' do
    relation = relations[:infos]
    relation.should be_instance_of(Relation::Graph::Node)
  end

  it 'finalizes info_contents relation' do
    relation = relations[:info_contents]
    relation.should be_instance_of(Relation::Graph::Node)
  end

  it 'finalizes songs-have-many-tags-through-song_tags relation' do
    name = :songs_X_song_tags_X_tags

    node = relations[name]

    node.should be_instance_of(Relation::Graph::Node)

    edge = relations.edge_for(name)
    edge.should be_instance_of(Relation::Graph::Edge)

    connector = relations.connectors[:"#{name}__tags"]
    connector.should be_instance_of(Relation::Graph::Connector)
  end

  it 'finalizes songs-have-one-good_tag-through-song_tag relation' do
    name = :songs_X_song_tags_X_good_tag

    node = relations[name]

    node.should be_instance_of(Relation::Graph::Node)

    edge = relations.edge_for(name)
    edge.should be_instance_of(Relation::Graph::Edge)

    connector = relations.connectors[:"#{name}__good_tag"]
    connector.should be_instance_of(Relation::Graph::Connector)
  end

  it 'finalizes songs-have-many-infos-through-tags relation' do
    name = :songs_X_song_tags_X_tags_X_infos
    node = relations[name]

    node.should be_instance_of(Relation::Graph::Node)

    edge = relations.edge_for(name)
    edge.should be_instance_of(Relation::Graph::Edge)

    connector = relations.connectors[:"#{name}__infos"]
    connector.should be_instance_of(Relation::Graph::Connector)
  end

  it 'finalizes songs-have-many-info_contents-through-infos relation' do
    name = :songs_X_song_tags_X_tags_X_infos_X_info_contents

    node = relations[name]

    node.should be_instance_of(Relation::Graph::Node)

    edge = relations.edge_for(name)
    edge.should be_instance_of(Relation::Graph::Edge)

    connector = relations.connectors[:"#{name}__info_contents"]
    connector.should be_instance_of(Relation::Graph::Connector)
  end

  it 'finalizes songs-have-many-good_info_contents-through-infos relation' do
    name = :songs_X_song_tags_X_tags_X_infos_X_good_info_contents

    node = relations[name]

    node.should be_instance_of(Relation::Graph::Node)

    edge = relations.edge_for(name)
    edge.should be_instance_of(Relation::Graph::Edge)

    connector = relations.connectors[:"#{name}__good_info_contents"]
    connector.should be_instance_of(Relation::Graph::Connector)
  end

  it 'finalizes tags-have-many-song_tags relation' do
    name = :tags_X_song_tags
    node = relations[name]

    node.should be_instance_of(Relation::Graph::Node)

    edge = relations.edge_for(name)
    edge.should be_instance_of(Relation::Graph::Edge)

    connector = relations.connectors[:"#{name}__song_tags"]
    connector.should be_instance_of(Relation::Graph::Connector)
  end

  it 'finalizes tags-have-many-songs-through-song_tags relation' do
    name = :tags_X_song_tags_X_songs
    node = relations[name]

    node.should be_instance_of(Relation::Graph::Node)

    edge = relations.edge_for(name)
    edge.should be_instance_of(Relation::Graph::Edge)

    connector = relations.connectors[:"#{name}__songs"]
    connector.should be_instance_of(Relation::Graph::Connector)
  end

  it 'finalizes song mapper' do
    DM_ENV[Song].relation.should be(relations[:songs])
  end

  it 'finalizes tag mapper' do
    DM_ENV[Tag].relation.should be(relations[:tags])
  end

  it 'finalizes song_tag mapper' do
    DM_ENV[SongTag].relation.should be(relations[:song_tags])
  end

  it 'finalizes info mapper' do
    DM_ENV[Info].relation.should be(relations[:infos])
  end

  it 'finalizes info content mapper' do
    DM_ENV[InfoContent].relation.should be(relations[:info_contents])
  end

  it 'finalizes song-song-tags mapper' do
    DM_ENV[Song].include(:song_tags).relation.should eql(relations[:songs_X_song_tags])
  end

  it 'finalizes song-song-tag mapper' do
    DM_ENV[Song].include(:song_tag).relation.should eql(relations[:songs_X_song_tags])
  end

  it 'finalizes song-tag-through-song_tag mapper' do
    DM_ENV[Song].include(:tag).relation.should eql(relations[:songs_X_song_tags_X_tags])
  end

  it 'finalizes song-tags mapper' do
    DM_ENV[Song].include(:tags).relation.should eql(relations[:songs_X_song_tags_X_tags])
  end

  it 'finalizes song-infos mapper' do
    DM_ENV[Song].include(:infos).relation.should eql(relations[:songs_X_song_tags_X_tags_X_infos])
  end

  it 'finalizes song-info-contents mapper' do
    DM_ENV[Song].include(:info_contents).relation.should be(relations[:songs_X_song_tags_X_tags_X_infos_X_info_contents])
  end

  it 'finalizes song-good-info-contents mapper' do
    DM_ENV[Song].include(:good_info_contents).relation.should be(relations[:songs_X_song_tags_X_tags_X_infos_X_good_info_contents])
  end
end
