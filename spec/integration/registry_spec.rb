require 'spec_helper'

require 'session/registry'
require 'mapper/virtus'

describe 'mapper registry' do
  let(:person_mapper) do
    Mapper::Mapper::Virtus.new(
      Example::Person,
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
    Example::Person.new(:id => 1,:firstname => 'Markus',:lastname => 'Schirp')
  end

  let(:dump) do
    { :id => 1, :firstname => 'Markus', :lastname => 'Schirp' }
  end

  let(:key) do
    { :id => 1 }
  end

  before do
    registry.register(Example::Person,person_mapper)
  end

  specify 'allows to resolve mappers for models' do
    registry.resolve_model(Example::Person).should eql(person_mapper)
  end

  specify 'allows to resolve mappers for objects' do
    registry.resolve_object(person).should eql(person_mapper)
  end

  specify 'allows to dump with objects' do
    registry.dump_object(person).should == dump
  end

  specify 'allows to load with model and dump' do
    object = registry.load_model(Example::Person, dump)
    object.attributes.should == person.attributes
  end

  specify 'allows to dump keys with object' do
    registry.dump_object_key(person).should == key
  end

  specify 'allows to load keys from dump' do
    registry.load_model_key(Example::Person,dump).should == key
  end
end
