require 'spec_helper_integration'

describe 'Relationship - Many To Many' do
  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 2, 1
    insert_song_tag 2, 1, 2

    # setup relation gateway to the join table as we don't need to map it to objects
    DataMapper.setup_relation_gateway(:postgres, :song_tags,
                                      [ [ :song_id, Integer ],
                                        [ :tag_id, Integer ] ])

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

    class TagMapper < DataMapper::Mapper::Relation::Base

      model         Tag
      relation_name :tags
      repository    :postgres

      map :id,   Integer, :to => :tag_id, :key => true
      map :name, String
    end

    class SongTagMapper < DataMapper::Mapper::Relation

      model Song

      map :id,    Integer, :to => :song_id, :key => true
      map :title, String
      map :tags,  Tag, :collection => true
    end

    class SongMapper < DataMapper::Mapper::Relation::Base

      model         Song
      relation_name :songs
      repository    :postgres

      map :id,    Integer, :key => true
      map :title, String

      has 0..n, :tags, :mapper => SongTagMapper, :through => :song_tags do |tags, relationship|
        song_tags = relationship.join_relation
        rename(:id => :song_id).join(song_tags).join(tags)
      end
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
