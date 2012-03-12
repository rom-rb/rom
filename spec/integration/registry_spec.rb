require 'spec_helper'

require 'session/registry'
require 'mapper/virtus'

describe 'mapper registry' do
  class Person
    include Virtus
    attribute :id,Integer
    attribute :firstname,String
    attribute :lastname,String
  end

  let(:person_mapper) do
    Mapper::Mapper::Virtus.new(Person,
      [
        Mapper::Mapper::Attribute.new(:id,:key => true),
        Mapper::Mapper::Attribute.new(:firstname),
        Mapper::Mapper::Attribute.new(:lastname)
      ]
    )
  end

  let(:registry) do
    Session::Registry.new
  end

  let(:person) do
    Person.new(:id => 1,:firstname => 'Markus',:lastname => 'Schirp')
  end

  let(:dump) do
    { :id => 1, :firstname => 'Markus', :lastname => 'Schirp' }
  end

  let(:key) do
    { :id => 1 }
  end

  before do
    registry.register(Person,person_mapper)
  end

  specify 'allows to register mappers for models' do
    registry.for(Person).should eql(person_mapper)
  end

  specify 'allows to dump with objects' do
    registry.dump(person).should == dump
  end

  specify 'allows to load with model and dump' do
    object = registry.load(Person, dump)
    object.attributes.should == person.attributes
  end

  specify 'allows to dump keys with object' do
    registry.dump_key(person).should == key
  end

  specify 'allows to load keys from dump' do
    registry.load_key(Person,dump).should == key
  end
end
