require 'spec_helper_integration'

unless DataMapper.engines[:postgres_arel]
  DataMapper.setup(
    :postgres_arel,
    'postgres://postgres@localhost/dm-mapper_test',
    DataMapper::Engine::Arel::Engine
  )
end

describe '[Arel] Relationship - Many To Many with generated mappers' do
  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 1, 1
    insert_song_tag 2, 2, 2

    class Song
      attr_reader :id, :title, :song_tags, :tags, :good_tags

      def initialize(attributes)
        @id, @title, @song_tags, @tags, @good_tags = attributes.values_at(
          :id, :title, :song_tags, :tags, :good_tags
        )
      end
    end

    class Tag
      attr_reader :id, :name, :song_tags, :songs

      def initialize(attributes)
        @id, @name, @song_tags, @songs = attributes.values_at(:id, :name, :song_tags, :songs)
      end
    end

    class SongTag
      attr_reader :song_id, :tag_id

      def initialize(attributes)
        @song_id, @tag_id = attributes.values_at(:song_id, :tag_id)
      end
    end

    class TagMapper < DataMapper::Mapper::Relation

      model         Tag
      relation_name :tags
      repository    :postgres_arel

      map :id,   Integer, :key => true
      map :name, String

      has 0..n, :song_tags, SongTag
      has 0..n, :songs, Song, :through => :song_tags
    end

    class SongTagMapper < DataMapper::Mapper::Relation

      model         SongTag
      relation_name :song_tags
      repository    :postgres_arel

      belongs_to :song, Song
      belongs_to :tag,  Tag

      map :id,      Integer, :key => true
      map :song_id, Integer
      map :tag_id,  Integer
    end

    class SongMapper < DataMapper::Mapper::Relation
      model         Song
      relation_name :songs
      repository    :postgres_arel

      map :id,    Integer, :key => true
      map :title, String

      has 0..n, :song_tags, SongTag

      has 0..n, :tags, Tag, :through => :song_tags

      has 0..n, :good_tags, Tag, :through => :song_tags do
        where(source.right.first.left[:name].eq('good'))
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :Tag)
    Object.send(:remove_const, :Song)
    Object.send(:remove_const, :SongTag)

    Object.send(:remove_const, :TagMapper)
    Object.send(:remove_const, :SongMapper)
    Object.send(:remove_const, :SongTagMapper)
  end

  it 'loads associated song_tags for songs' do
    pending

    mapper = DataMapper[Song].include(:song_tags)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('foo')
    song1.song_tags.should have(1).item
    song1.song_tags.first.song_id.should eql(song1.id)
    song1.song_tags.first.tag_id.to_i.should eql(1)

    song2.title.should eql('bar')
    song2.song_tags.should have(1).item
    song2.song_tags.first.song_id.should eql(song2.id)
    song2.song_tags.first.tag_id.to_i.should eql(2)
  end

  it 'loads associated tags for songs' do
    pending

    mapper = DataMapper[Song].include(:tags)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('foo')
    song1.tags.should have(1).item
    song1.tags.first.name.should eql('good')

    song2.title.should eql('bar')
    song2.tags.should have(1).item
    song2.tags.first.name.should eql('bad')
  end

  it 'loads associated tags with name = good' do
    pending

    mapper = DataMapper[Song].include(:good_tags)
    songs  = mapper.include(:good_tags).to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('foo')
    song.good_tags.should have(1).item
    song.good_tags.first.name.should eql('good')
  end

  it 'loads associated song_tags for tags' do
    pending

    mapper = DataMapper[Tag].include(:song_tags)
    tags   = mapper.to_a

    tags.should have(2).item

    tag1, tag2 = tags

    tag1.name.should eql('good')
    tag1.song_tags.should have(1).item
    tag1.song_tags.first.song_id.should eql(tag1.id)

    tag2.name.should eql('bad')
    tag2.song_tags.should have(1).item
    tag2.song_tags.first.tag_id.should eql(tag2.id)
  end

  it 'loads associated songs for tags' do
    pending

    mapper = DataMapper[Tag].include(:songs)
    tags   = mapper.to_a

    tags.should have(2).item

    tag1, tag2 = tags

    tag1.name.should eql('good')
    tag1.songs.should have(1).item
    tag1.songs.first.title.should eql('foo')

    tag2.name.should eql('bad')
    tag2.songs.should have(1).item
    tag2.songs.first.title.should eql('bar')
  end
end
