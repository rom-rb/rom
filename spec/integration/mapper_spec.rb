require 'spec_helper'

require 'session/registry'

require 'mapper'
require 'mapper/virtus'
require 'mapper/mongo'

require 'logger'

describe 'mapper integration' do
  class Person
    include Virtus
    attribute :id,BSON::ObjectId, :default => proc { BSON::ObjectId.new }
    attribute :firstname,String
    attribute :lastname,String
  end

  let(:db) do
    host = ENV.fetch('MONGO_HOST','localhost:27017')
    connection = ::Mongo::Connection.new(host,
      :safe => true
    )
    db = ENV.fetch('MONGO_DB','session_test')
    if ENV.key?('MONGO_AUTH')
      user,password = ENV.fetch('MONGO_AUTH')
      connection.add_auth(db,user,password)
    end
    connection.db(db)
  end

  let(:people_collection) do
    db.collection(:people)
  end

  let(:person_mapper) do
    Mapper::Mapper::Virtus.new(
      Person,
      [
        Mapper::Mapper::Attribute.new(:id,:as => '_id'),
        Mapper::Mapper::Attribute.new(:firstname),
        Mapper::Mapper::Attribute.new(:lastname),
      ]
    )
  end

  let(:mongo_person_mapper) do
    Mapper::Mapper::Mongo.new(
      :collection => people_collection,
      :mapper => person_mapper
    )
  end

  let(:mapper) do
    mapper = Session::Registry.new
    mapper.register(Person,mongo_person_mapper)
  end

  let(:session) do
    Session::Session.new(mapper)
  end

  let(:person) do
    Person.new(:firstname => 'John', :lastname => 'Doe')
  end

  before do
    people_collection.remove({})
  end

  specify 'allows object inserts' do
    session.insert(person).commit

    people_collection.find_one.should == {
      '_id' => person.id,
      'firstname' => person.firstname,
      'lastname' => person.lastname
    }
  end

  specify 'allows object updates' do
    session.insert(person).commit

    person.firstname = 'Jane'

    session.dirty?(person).should be_true

    session.persist(person).commit

    people_collection.find_one.should == {
      '_id' => person.id,
      'firstname' => person.firstname,
      'lastname' => person.lastname
    }
  end

  specify 'allows object deletions' do
    session.insert(person).commit

    session.delete(person).commit

    people_collection.count.should be_zero
  end

  specify 'allows to find object' do
    session.insert(person).commit

    session.first(Person,:firstname => person.firstname).should equal(person)
  end

  specify 'allows to find objects' do
    session.insert(person).commit

    session.all(Person,:firstname => person.firstname).to_a.should == [person]
  end
end
