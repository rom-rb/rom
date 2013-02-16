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

  it 'loads all followed people' do
    pending if RUBY_VERSION < '1.9'

    people = DM_ENV[person_model].include(:followed_people).to_a

    john = people[0]
    jane = people[1]

    john.followed_people.count.should == 1
    john.followed_people.first.id.should eql(jane.id)
    john.followed_people.first.name.should eql(jane.name)
  end

  it 'loads all followers' do
    pending if RUBY_VERSION < '1.9'

    people = DM_ENV[person_model].include(:followers).to_a

    john = people[0]
    jane = people[1]

    john.followers.count.should == 1
    john.followers.first.id.should eql(jane.id)
    john.followers.first.name.should eql(jane.name)
  end
end
