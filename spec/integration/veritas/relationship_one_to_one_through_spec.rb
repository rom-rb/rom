require 'spec_helper_integration'

describe 'Relationship - One To One through with generated mappers' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 2, 1
    insert_song_tag 2, 1, 2

    tag_mapper

    song_tag_mapper.belongs_to :song, song_model
    song_tag_mapper.belongs_to :tag,  tag_model

    song_mapper.has 1, :song_tag, song_tag_model
    song_mapper.has 1, :tag, tag_model, :through => :song_tag
    song_mapper.has 1, :good_tag, tag_model, :through => :song_tag, :via => :tag do
      restrict { |r| r.name.eq('good') }
    end
  end

  it 'loads associated tag' do
    mapper = DM_ENV[song_model].include(:tag)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('bar')
    song1.tag.name.should eql('good')

    song2.title.should eql('foo')
    song2.tag.name.should eql('bad')
  end

  it 'loads associated restricted tag' do
    mapper = DM_ENV[song_model].include(:good_tag)
    songs = mapper.to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('bar')
    song.good_tag.name.should eql('good')
  end
end
