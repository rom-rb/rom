require 'spec_helper_integration'

describe 'Relationship - Many-To-Many-Through with generated mappers' do
  include_context 'Models and Mappers'

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

    tag_mapper.has 0..n, :infos, info_model

    info_mapper.belongs_to :tag, tag_model
    info_mapper.has 0..n, :info_contents, info_content_model

    info_content_mapper.belongs_to :info, info_model

    song_tag_mapper.belongs_to :song, song_model
    song_tag_mapper.belongs_to :tag,  tag_model

    song_mapper.has 0..n, :song_tags, song_tag_model
    song_mapper.has 0..n, :tags, tag_model, :through => :song_tags

    song_mapper.has 0..n, :good_tags, tag_model, :through => :song_tags do |source, target|
      source.where(target[:name].eq('good'))
    end

    song_mapper.has 0..n, :infos, info_model, :through => :tags
    song_mapper.has 0..n, :good_infos, info_model, :through => :good_tags, :via => :infos
    song_mapper.has 0..n, :info_contents, info_content_model, :through => :infos

    song_mapper.has 0..n, :good_info_contents, info_content_model, :through => :infos, :via => :info_contents do |source, target|
      source.where(target[:content].eq('really, really good'))
    end
  end

  it 'loads associated tag infos' do
    mapper = DM_ENV[song_model].include(:infos)

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

  it 'loads associated good infos' do
    pending if RUBY_VERSION < '1.9'

    mapper = DM_ENV[song_model].include(:good_infos)

    songs = mapper.to_a

    songs.should have(1).items

    song = songs.first

    song.title.should eql('foo')

    song.good_infos.should have(1).item
    song.good_infos.first.text.should eql('really good')
  end

  it 'loads associated tag info contents' do
    mapper = DM_ENV[song_model].include(:info_contents)
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
    mapper = DM_ENV[song_model].include(:good_info_contents)
    songs = mapper.to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('foo')

    song.good_info_contents.should have(1).item
    song.good_info_contents.first.content.should eql('really, really good')
  end
end
