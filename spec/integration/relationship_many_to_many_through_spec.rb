require 'spec_helper_integration'

describe 'Relationship - Many To Many with generated mappers' do
  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_info 1, 1, "really good"
    insert_info 2, 2, "really bad"

    insert_info_content 1, 1, "really, really good"
    insert_info_content 2, 2, "really, really bad"

    insert_song_tag 1, 1, 1
    insert_song_tag 2, 2, 2

    class Song
      attr_reader :id, :title, :tags, :infos, :info_contents, :good_info_contents

      def initialize(attributes)
        @id, @title, @tags, @infos, @info_contents, @good_info_contents = attributes.values_at(
          :id, :title, :tags, :infos, :info_contents, :good_info_contents
        )
      end
    end

    class Tag
      attr_reader :id, :name

      def initialize(attributes)
        @id, @name = attributes.values_at(:id, :name)
      end
    end

    class Info
      attr_reader :id, :text

      def initialize(attributes)
        @id, @text = attributes.values_at(:id, :text)
      end
    end

    class InfoContent
      attr_reader :id, :content

      def initialize(attributes)
        @id, @content = attributes.values_at(:id, :content)
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
      repository    :postgres

      map :id,   Integer, :key => true
      map :name, String
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

      has 0..n, :infos, Info, :through => :tags, :target_key => :tag_id

      has 0..n, :info_contents, InfoContent, :through => :infos, :target_key => :info_id

      has 0..n, :good_info_contents, InfoContent, :through => :infos do
        restrict { |r| r.info_content_content.eq('really, really good') }
      end
    end
  end

  it 'loads associated tag infos' do
    mapper = DataMapper[Song].include(:infos)

    songs = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('foo')

    song1.infos.should have(1).item
    song1.infos.first.text.should eql('really good')

    song2.title.should eql('bar')

    song2.infos.should have(1).item
    song2.infos.first.text.should eql('really bad')
  end

  it 'loads associated tag info contents' do
    pending "this passes when run in isolation. probably some post-run clean up issue" if RUBY_VERSION < '1.9'

    mapper = DataMapper[Song].include(:info_contents)
    songs = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('foo')

    song1.info_contents.should have(1).item
    song1.info_contents.first.content.should eql('really, really good')

    song2.title.should eql('bar')

    song2.info_contents.should have(1).item
    song2.info_contents.first.content.should eql('really, really bad')
  end

  it 'loads associated restricted tag info contents' do
    mapper = DataMapper[Song].include(:good_info_contents)
    songs = mapper.to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('foo')

    song.good_info_contents.should have(1).item
    song.good_info_contents.first.content.should eql('really, really good')
  end
end
