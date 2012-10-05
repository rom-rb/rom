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

    class Tag
      include DataMapper::Model

      attribute :id,   Integer
      attribute :name, String
    end

    class SongTag
      include DataMapper::Model

      attribute :song_id, Integer
      attribute :tag_id,  Integer
    end

    class Song
      include DataMapper::Model

      attribute :id,    Integer
      attribute :title, String
      attribute :tag,   Tag
    end

    DataMapper.generate_mapper_for(Tag, :postgres) do
      key :id
    end

    DataMapper.generate_mapper_for(SongTag, :postgres) do
      key :song_id, :tag_id
    end

    DataMapper.generate_mapper_for(Song, :postgres) do
      key :id

      has 1, :song_tag, SongTag
      # TODO debug
      has 1, :tag, Tag, :through => :song_tag if RUBY_VERSION >= '1.9'
    end
  end

  it 'loads associated tag' do
    pending if RUBY_VERSION < '1.9'

    mapper = DataMapper[Song].include(:tag)
    songs = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('bar')
    song1.tag.name.should eql('good')

    song2.title.should eql('foo')
    song2.tag.name.should eql('bad')
  end
end
