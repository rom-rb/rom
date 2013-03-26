require 'spec_helper_integration'

describe 'Relationship - Many To Many with generated mappers' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 1, 1
    insert_song_tag 2, 2, 2

    insert_info 1, 1, 'really good'
    insert_info 2, 2, 'really bad'

    insert_info_content 1, 1, 'really, really good'
    insert_info_content 2, 2, 'really, really bad'

    tag_mapper.has 0..n, :song_tags, song_tag_model
    tag_mapper.has 0..n, :songs, song_model, :through => :song_tags
    tag_mapper.has 0..n, :infos, info_model

    song_tag_mapper.belongs_to :song, song_model
    song_tag_mapper.belongs_to :tag,  tag_model

    info_mapper.belongs_to :tag, tag_model
    info_mapper.has 0..n, :info_contents, info_content_model

    info_content_mapper.belongs_to :info, info_model

    song_mapper.has 0..n, :song_tags, song_tag_model
    song_mapper.has 0..n, :tags, tag_model, :through => :song_tags

    song_mapper.has 0..n, :good_tags, tag_model, :through => :song_tags, :via => :tag do
      restrict { |r| r.name.eq('good') }
    end

    song_mapper.has 0..n, :infos, info_model, :through => :tags

    song_mapper.has 0..n, :good_infos, info_model, :through => :good_tags, :via => :infos

    song_mapper.has 0..n, :info_contents, info_content_model, :through => :infos

    song_mapper.has 0..n, :good_info_contents, info_content_model, :through => :infos, :via => :info_contents do
      restrict { |r| r.content.eq('really, really good') }
    end
  end

  it 'loads associated song_tags for songs' do
    mapper = DM_ENV[song_model].include(:song_tags)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs.sort_by(&:id)

    song1.title.should eql('foo')
    song1.song_tags.should have(1).item
    song1.song_tags.first.song_id.should eql(song1.id)
    song1.song_tags.first.tag_id.should eql(1)

    song2.title.should eql('bar')
    song2.song_tags.should have(1).item
    song2.song_tags.first.song_id.should eql(song2.id)
    song2.song_tags.first.tag_id.should eql(2)
  end

  it 'loads associated tags for songs' do
    mapper = DM_ENV[song_model].include(:tags)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs.sort_by(&:id)

    song1.title.should eql('foo')
    song1.tags.should have(1).item
    song1.tags.first.name.should eql('good')

    song2.title.should eql('bar')
    song2.tags.should have(1).item
    song2.tags.first.name.should eql('bad')
  end

  it 'loads associated tags with name = good for songs' do
    mapper = DM_ENV[song_model].include(:good_tags)
    songs  = mapper.include(:good_tags).to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('foo')
    song.good_tags.should have(1).item
    song.good_tags.first.name.should eql('good')
  end

  it 'loads associated song_tags for tags' do
    mapper = DM_ENV[tag_model].include(:song_tags)
    tags   = mapper.to_a

    tags.should have(2).item

    tag1, tag2 = tags.sort_by(&:id)

    tag1.name.should eql('good')
    tag1.song_tags.should have(1).item
    tag1.song_tags.first.song_id.should eql(tag1.id)

    tag2.name.should eql('bad')
    tag2.song_tags.should have(1).item
    tag2.song_tags.first.tag_id.should eql(tag2.id)
  end

  it 'loads associated songs for tags' do
    mapper = DM_ENV[tag_model].include(:songs)
    tags   = mapper.to_a

    tags.should have(2).item

    tag1, tag2 = tags.sort_by(&:id)

    tag1.name.should eql('good')
    tag1.songs.should have(1).item
    tag1.songs.first.title.should eql('foo')

    tag2.name.should eql('bad')
    tag2.songs.should have(1).item
    tag2.songs.first.title.should eql('bar')
  end
  it 'loads associated :infos for songs' do
    mapper = DM_ENV[song_model].include(:infos)

    songs = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs.sort_by(&:id)

    song1.title.should eql('foo')
    song1.infos.should have(1).item
    song1.infos.first.text.should eql('really good')

    song2.title.should eql('bar')
    song2.infos.should have(1).item
    song2.infos.first.text.should eql('really bad')
  end

  it 'loads associated :good_infos for songs' do
    pending if RUBY_VERSION < '1.9'

    mapper = DM_ENV[song_model].include(:good_infos)

    songs = mapper.to_a

    songs.should include(song)
  end

  it 'loads associated tag :info_contents for songs' do
    mapper = DM_ENV[song_model].include(:info_contents)
    songs = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs.sort_by(&:id)

    song1.title.should eql('foo')
    song1.info_contents.should have(1).item
    song1.info_contents.first.content.should eql('really, really good')

    song2.title.should eql('bar')
    song2.info_contents.should have(1).item
    song2.info_contents.first.content.should eql('really, really bad')
  end

  it 'loads associated :good_info_contents for songs' do
    mapper = DM_ENV[song_model].include(:good_info_contents)
    songs = mapper.to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('foo')
    song.good_info_contents.should have(1).item
    song.good_info_contents.first.content.should eql('really, really good')
  end
end
