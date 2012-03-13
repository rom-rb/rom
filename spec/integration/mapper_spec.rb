require 'spec_helper'

require 'session/registry'

require 'mapper'
require 'mapper/virtus'
require 'mapper/mongo'

require 'logger'

describe 'mapper integration' do
  let(:db) do
    host = ENV.fetch('MONGO_HOST','localhost')
    connection = ::Mongo::Connection.new(
      host,
      27017,
      :safe => true,
      :logger => Logger.new($stderr,Logger::DEBUG)
    )
    db = ENV.fetch('MONGO_DB','session_test')
    if ENV.key?('MONGO_AUTH')
      user,password = ENV.fetch('MONGO_AUTH').split(':',2)
      connection.add_auth(db,user,password)
    end
    connection.db(db)
  end

  let(:people_collection) do
    db.collection(:people)
  end

  let(:person_mapper) do
    Mapper::Mapper::Virtus.new(
      Example::Person,
      [
        Mapper::Mapper::Attribute.new(:id,:as => :_id, :key => true),
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
    mapper.register(Example::Person,mongo_person_mapper)
  end

  let(:session) do
    Session::Session.new(mapper)
  end

  let(:person) do
    Example::Person.new(:firstname => 'John', :lastname => 'Doe')
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

    session.first(Example::Person,:firstname => person.firstname).should equal(person)
  end

  let(:other_person) do
    Example::Person.new(:firstname => 'Suzan', :lastname => 'Doe')
  end

  specify 'allows to find objects' do
    session.insert(person).commit
    session.insert(other_person).commit

    people = session.all(Example::Person,{}).to_a
    people.sort_by!(&:firstname)
    people.should == [person,other_person].sort_by(&:firstname)
  end

  specify 'allows to stream objects' do
    session.insert(person).commit
    session.insert(other_person).commit

    people = []

    session.all(Example::Person,{}).each do |person|
      people << person
    end

    people.sort_by!(&:firstname)

    people.should == [person,other_person].sort_by(&:firstname)
  end
end
