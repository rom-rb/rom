require 'spec_helper_integration'

describe 'Relationship - Many To Many with generated mappers' do
  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 2, 1
    insert_song_tag 2, 1, 2

    class Song
      attr_reader :id, :title, :song_tags, :tags, :good_tags

      def initialize(attributes)
        @id, @title, @song_tags, @tags, @good_tags = attributes.values_at(
          :id, :title, :song_tags, :tags, :good_tags
        )
      end
    end

    class Tag
      attr_reader :id, :name

      def initialize(attributes)
        @id, @name = attributes.values_at(:id, :name)
      end
    end

    class SongTag
      attr_reader :song_id, :tag_id

      def initialize(attributes)
        @song_id, @tag_id = attributes.values_at(:song_id, :tag_id)
      end
    end

    class TagMapper < DataMapper::Mapper::Relation::Base

      model         Tag
      relation_name :tags
      repository    :postgres

      map :id,   Integer, :key => true
      map :name, String
    end

    class SongTagMapper < DataMapper::Mapper::Relation::Base

      model         SongTag
      relation_name :song_tags
      repository    :postgres

      map :song_id, Integer, :key => true
      map :tag_id,  Integer, :key => true
    end

    class SongMapper < DataMapper::Mapper::Relation::Base
      model         Song
      relation_name :songs
      repository    :postgres

      map :id,    Integer, :key => true
      map :title, String

      has 0..n, :song_tags, SongTag

      # TODO debug
      if RUBY_VERSION >= '1.9'

        has 0..n, :tags, Tag, :through => :song_tags

        has 0..n, :good_tags, Tag, :through => :song_tags do
          restrict { |r| r.tag_name.eq('good') }
        end

      end
    end
  end

  it 'loads associated song_tags' do
    pending if RUBY_VERSION < '1.9'

    mapper = DataMapper[Song].include(:song_tags)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('bar')
    song1.song_tags.should have(1).item
    song1.song_tags.first.song_id.should eql(song1.id)
    song1.song_tags.first.tag_id.should eql(1)

    song2.title.should eql('foo')
    song2.song_tags.should have(1).item
    song2.song_tags.first.song_id.should eql(song2.id)
    song2.song_tags.first.tag_id.should eql(2)
  end

  it 'loads associated tags' do
    pending if RUBY_VERSION < '1.9'

    mapper = DataMapper[Song].include(:tags)
    songs = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('bar')
    song1.tags.should have(1).item
    song1.tags.first.name.should eql('good')

    song2.title.should eql('foo')
    song2.tags.should have(1).item
    song2.tags.first.name.should eql('bad')
  end

  it 'loads associated tags with name = good' do
    pending

    mapper = DataMapper[Song]
    songs = mapper.include(:good_tags).to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('bar')
    song.good_tags.should have(1).item
    song.good_tags.first.name.should eql('good')
  end
end
