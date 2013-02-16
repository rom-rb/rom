require 'spec_helper_integration'

describe 'Relationship - One To One with generated mapper' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_user 1, 'John',  18
    insert_user 2, 'Jane',  21
    insert_user 3, 'Piotr', 29

    insert_address 1, 3, 'Street 1/2', 'Krakow',  '12345'
    insert_address 2, 2, 'Street 1/2', 'Chicago', '54321'
    insert_address 3, 1, 'Street 2/4', 'Boston',  '67890'

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 2, 1
    insert_song_tag 2, 1, 2

    user_mapper.has 1, :address, address_model
    user_mapper.has 1, :home_address, address_model do
      restrict { |r| r.city.eq('Krakow') }
    end

    address_mapper.belongs_to :user, user_model

    tag_mapper

    song_tag_mapper.belongs_to :song, song_model
    song_tag_mapper.belongs_to :tag,  tag_model

    song_mapper.has 1, :song_tag, song_tag_model
    song_mapper.has 1, :tag, tag_model, :through => :song_tag
    song_mapper.has 1, :good_tag, tag_model, :through => :song_tag, :via => :tag do
      restrict { |r| r.name.eq('good') }
    end
  end

  it 'loads the object without association' do
    user = DM_ENV[user_model].all.first

    user.should be_instance_of(user_model)
    user.id.should eql(1)
    user.name.should eql('John')
    user.age.should eql(18)
  end

  it 'loads associated object' do
    mapper  = DM_ENV[user_model].include(:address)
    user    = mapper.all.last
    address = user.address

    address.should be_instance_of(address_model)
    address.id.should eql(3)
    address.city.should eql('Boston')
  end

  it 'loads restricted association' do
    mapper  = DM_ENV[user_model].include(:home_address)
    address = mapper.to_a.first.home_address

    address.should be_instance_of(address_model)
    address.id.should eql(1)
    address.city.should eql('Krakow')
  end

  it 'finds users with matching address' do
    user_address_mapper = DM_ENV[user_model].include(:address)
    users               = user_address_mapper.restrict { |r| r.city.eq('Krakow') }.to_a

    users.should have(1).item

    user = users.first

    user.name.should eql('Piotr')
    user.address.id.should eql(1)
    user.address.city.should eql('Krakow')
  end

  it 'finds users with matching address using mapper query API' do
    pending "Query doesn't support nested conditions"

    users = user_mapper.include(:address).find(:address => { :city => "Krakow" })

    users.should have(1).item

    user = users.first

    user.name.should eql('Piotr')
    user.address.id.should eql(1)
    user.address.city.should eql('Krakow')
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
