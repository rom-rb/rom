shared_context 'Models and Mappers' do
  def n() DataMapper::Infinity end

  def user_model()         @user_model         ||= mock_model('User') end
  def order_model()        @order_model        ||= mock_model('Order') end
  def address_model()      @address_model      ||= mock_model('Address') end
  def song_model()         @song_model         ||= mock_model('Song') end
  def tag_model()          @tag_model          ||= mock_model('Tag') end
  def song_tag_model()     @song_tag_model     ||= mock_model('SongTag') end
  def info_model()         @info_model         ||= mock_model('Info') end
  def info_content_model() @info_content_model ||= mock_model('InfoContent') end
  def person_model()       @person_model       ||= mock_model('Person') end
  def link_model()         @link_model         ||= mock_model('Link') end

  def user_mapper
    @user_mapper ||= DM_ENV.build(user_model, DM_ADAPTER) do
      relation_name :users

      map :id,   Integer, :key => true
      map :name, String,  :to  => :username
      map :age,  Integer
    end
  end

  def order_mapper
    @order_mapper ||= DM_ENV.build(order_model, DM_ADAPTER) do
      relation_name :orders

      map :id,      Integer, :key => true
      map :user_id, Integer
      map :product, String
    end
  end

  def address_mapper
    @address_mapper ||= DM_ENV.build(address_model, DM_ADAPTER) do
      relation_name :addresses

      map :id,      Integer, :key => true
      map :user_id, Integer
      map :street,  String
      map :city,    String
      map :zipcode, String
    end
  end

  def tag_mapper
    @tag_mapper ||= DM_ENV.build(tag_model, DM_ADAPTER) do
      relation_name :tags

      map :id,   Integer, :key => true
      map :name, String
    end
  end

  def info_mapper
    @info_mapper ||= DM_ENV.build(info_model, DM_ADAPTER) do
      relation_name :infos

      map :id,     Integer, :key => true
      map :tag_id, Integer
      map :text,   String
    end
  end

  def info_content_mapper
    @info_content_mapper ||= DM_ENV.build(info_content_model, DM_ADAPTER) do
      relation_name :info_contents

      map :id,      Integer, :key => true
      map :info_id, Integer
      map :content, String
    end
  end

  def song_tag_mapper
    @song_tag_mapper ||= DM_ENV.build(song_tag_model, DM_ADAPTER) do
      relation_name :song_tags

      map :song_id, Integer, :key => true
      map :tag_id,  Integer, :key => true
    end
  end

  def song_mapper
    @song_mapper ||= DM_ENV.build(song_model, DM_ADAPTER) do
      relation_name :songs

      map :id,    Integer, :key => true
      map :title, String
    end
  end

  def person_mapper
    @person_mapper ||= DM_ENV.build(person_model, DM_ADAPTER) do
      relation_name :people

      map :id,        Integer, :key => true
      map :parent_id, Integer
      map :name,      String
    end
  end

  def link_mapper
    @link_mapper ||= DM_ENV.build(link_model, DM_ADAPTER) do
      relation_name :people_links

      map :id,          Integer, :key => true
      map :follower_id, Integer
      map :followed_id, Integer
    end
  end
end
