shared_context 'Models and Mappers' do
  let(:n) { DataMapper::Infinity }

  let!(:user_model)         { mock_model('User') }
  let!(:order_model)        { mock_model('Order') }
  let!(:address_model)      { mock_model('Address') }
  let!(:song_model)         { mock_model('Song') }
  let!(:tag_model)          { mock_model('Tag') }
  let!(:song_tag_model)     { mock_model('SongTag') }
  let!(:info_model)         { mock_model('Info') }
  let!(:info_content_model) { mock_model('InfoContent') }
  let!(:person_model)       { mock_model('Person') }
  let!(:link_model)         { mock_model('Link') }

  let!(:user_mapper) {
    DM_ENV.build(user_model, :postgres) do
      relation_name :users

      map :id,   Integer, :key => true
      map :name, String,  :to  => :username
      map :age,  Integer
    end
  }

  let!(:order_mapper) {
    DM_ENV.build(order_model, :postgres) do
      relation_name :orders

      map :id,      Integer, :key => true
      map :user_id, Integer
      map :product, String
    end
  }

  let!(:address_mapper) {
    DM_ENV.build(address_model, :postgres) do
      relation_name :addresses

      map :id,      Integer, :key => true
      map :user_id, Integer
      map :street,  String
      map :city,    String
      map :zipcode, String
    end
  }

  let!(:tag_mapper) {
    DM_ENV.build(tag_model, :postgres) do
      relation_name :tags

      map :id,   Integer, :key => true
      map :name, String
    end
  }

  let!(:info_mapper) {
    DM_ENV.build(info_model, :postgres) do
      relation_name :infos

      map :id,     Integer, :key => true
      map :tag_id, Integer
      map :text,   String
    end
  }

  let!(:info_content_mapper) {
    DM_ENV.build(info_content_model, :postgres) do
      relation_name :info_contents

      map :id,      Integer, :key => true
      map :info_id, Integer
      map :content, String
    end
  }

  let!(:song_tag_mapper) {
    DM_ENV.build(song_tag_model, :postgres) do
      relation_name :song_tags

      map :song_id, Integer, :key => true
      map :tag_id,  Integer, :key => true
    end
  }

  let!(:song_mapper) {
    DM_ENV.build(song_model, :postgres) do
      relation_name :songs

      map :id,    Integer, :key => true
      map :title, String
    end
  }

  let!(:person_mapper) {
    DM_ENV.build(person_model, :postgres) do
      relation_name :people

      map :id,        Integer, :key => true
      map :parent_id, Integer
      map :name,      String
    end
  }

  let!(:link_mapper) {
    DM_ENV.build(link_model, :postgres) do
      relation_name :people_links

      map :id,          Integer, :key => true
      map :follower_id, Integer
      map :followed_id, Integer
    end
  }
end
