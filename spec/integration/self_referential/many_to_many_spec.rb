require 'spec_helper_integration'

describe 'Relationship - Self referential Many To Many' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_person 1, 'John'
    insert_person 2, 'Jane'
    insert_person 3, 'Alice'

    insert_people_link 1, 1, 2
    insert_people_link 2, 2, 1
    insert_people_link 3, 3, 2

    person_mapper.has 0..n, :links_to_followed_people, link_model, :target_key => [:follower_id]
    person_mapper.has 0..n, :links_to_followers,       link_model, :target_key => [:followed_id]

    person_mapper.has 0..n, :followed_people, person_model,
      :through => :links_to_followed_people,
      :via     => :followed

    person_mapper.has 0..n, :followers, person_model,
      :through => :links_to_followers,
      :via     => :follower

    link_mapper.belongs_to :follower, person_model
    link_mapper.belongs_to :followed, person_model
  end

  let(:john_with_followed_people)  { person_model.new(:id => 1, :name => 'John',  :parent_id => nil, :followed_people => [ jane ]) }
  let(:jane_with_followed_people)  { person_model.new(:id => 2, :name => 'Jane',  :parent_id => nil, :followed_people => [ john ]) }
  let(:alice_with_followed_people) { person_model.new(:id => 3, :name => 'Alice', :parent_id => nil, :followed_people => [ jane ]) }

  let(:john_with_followers)        { person_model.new(:id => 1, :name => 'John',  :parent_id => nil, :followers => [ jane        ]) }
  let(:jane_with_followers)        { person_model.new(:id => 2, :name => 'Jane',  :parent_id => nil, :followers => [ john, alice ]) }
  let(:alice_with_followers)       { person_model.new(:id => 3, :name => 'Alice', :parent_id => nil, :followers => [             ]) }

  let(:john)  { person_model.new(:id => 1, :name => 'John',  :parent_id => nil ) }
  let(:jane)  { person_model.new(:id => 2, :name => 'Jane',  :parent_id => nil ) }
  let(:alice) { person_model.new(:id => 3, :name => 'Alice', :parent_id => nil ) }

  it 'loads all followed people' do
    pending if RUBY_VERSION < '1.9'

    DM_ENV[person_model].include(:followed_people).to_a.should =~ [
      john_with_followed_people,
      jane_with_followed_people,
      alice_with_followed_people
    ]
  end

  it 'loads all followers' do
    pending "Loading a person's followers doesn't work yet"

    DM_ENV[person_model].include(:followers).to_a.should =~ [
      john_with_followers,
      jane_with_followers,
      alice_with_followers
    ]
  end
end
