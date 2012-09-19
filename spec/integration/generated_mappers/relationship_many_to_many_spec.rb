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
      attr_reader :id, :title, :tags

      def initialize(attributes)
        @id, @title, @tags = attributes.values_at(:id, :title, :tags)
      end
    end

    class Tag
      attr_reader :id, :name

      def initialize(attributes)
        @id, @name, = attributes.values_at(:id, :name)
      end
    end

    class SongTag
      attr_reader :song_id, :tag_id

      def initialize(attributes)
        @song_id, @tag_id = attributes.values_at(:song_id, :tag_id)
      end
    end

    class TagMapper < DataMapper::Mapper::VeritasMapper
      map :id,   :type => Integer, :key => true
      map :name, :type => String

      model         Tag
      relation_name :tags
      repository    :postgres
    end

    class SongTagMapper < DataMapper::Mapper::VeritasMapper
      map :song_id, :type => Integer
      map :tag_id,  :type => Integer

      model SongTag
      relation_name :song_tags
      repository :postgres
    end

    class SongMapper < DataMapper::Mapper::VeritasMapper
      model         Song
      relation_name :songs
      repository    :postgres

      map :id,    :type => Integer, :key => true
      map :title, :type => String

      has_many :song_tags, SongTag, :target_key => :song_id
      has_many :tags, Tag, :through => :song_tags
    end
  end

  it 'loads associated object' do
    pending if RUBY_VERSION < '1.9'

    mapper = DataMapper[Song]
    songs = mapper.include(:tags).to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('bar')
    song1.tags.should have(1).item
    song1.tags.first.name.should eql('good')

    song2.title.should eql('foo')
    song2.tags.should have(1).item
    song2.tags.first.name.should eql('bad')
  end
end
