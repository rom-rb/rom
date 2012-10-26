require 'spec_helper_integration'

describe 'Relationship - One To One through with generated mappers' do
  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 2, 1
    insert_song_tag 2, 1, 2

    class Song
      attr_reader :id, :title, :song_tag, :tag, :good_tag

      def initialize(attributes)
        @id, @title, @song_tag, @tag, @good_tag = attributes.values_at(
          :id, :title, :song_tag, :tag, :good_tag
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

      map :id,      Integer, :key => true
      map :song_id, Integer
      map :tag_id,  Integer
    end

    class SongMapper < DataMapper::Mapper::Relation::Base
      model         Song
      relation_name :songs
      repository    :postgres

      map :id,    Integer, :key => true
      map :title, String

      has 1, :song_tag, SongTag

      has 1, :tag, Tag, :through => :song_tag, :target_key => :tag_id

      has 1, :good_tag, Tag, :through => :song_tag do
        restrict { |r| r.tag_name.eq('good') }
      end
    end
  end

  it 'loads associated tag' do
    pending

    mapper = DataMapper[Song].include(:tag)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('bar')
    song1.tag.name.should eql('good')

    song2.title.should eql('foo')
    song2.tag.name.should eql('bad')
  end

  it 'loads associated restricted tag' do
    pending

    mapper = DataMapper[Song].include(:good_tag)
    songs = mapper.to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('bar')
    song.good_tag.name.should eql('good')
  end
end
