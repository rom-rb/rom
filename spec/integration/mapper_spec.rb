# encoding: utf-8

require 'spec_helper'

class Address
  include Anima.new(:id, :city, :zip)
end

class Task
  include Anima.new(:id, :name)
end

class Person
  include Anima.new(:id, :name, :address, :tasks)
end

describe ROM::Mapper do

  let(:task_hash)      { Hash[id: 1, name: 'DOIT'] }
  let(:address_hash)   { Hash[id: 1, city: 'Linz', zip: 4040] }
  let(:person_hash)    { Hash[id: 1, name: 'John', address: address_hash, tasks: [task_hash]] }

  let(:address)        { Address.new(address_hash) }
  let(:task)           { Task.new(task_hash) }
  let(:person)         { Person.new(id: 1, name: 'John', address: address, tasks: [task]) }

  let(:mappers)        { ROM::Mapper::Registry.build(mappings) }

  let(:address_mapper) { mappers[Address] }
  let(:person_mapper)  { mappers[Person]  }

  shared_examples_for 'mapping' do
    it 'supports objects with primitive attributes' do
      expect(address_mapper.load(address_hash)).to eql(address)
      expect(address_mapper.dump(address)).to eql(address_hash)
    end

    it 'supports objects with primitive attributes, embedded values and collections' do
      expect(person_mapper.load(person_hash)).to eql(person)
      expect(person_mapper.dump(person)).to eql(person_hash)
    end

    it 'raises an error when trying to access an unknown mapper' do
      expect { mappers[:unknown] }.to raise_error(ROM::Mapper::UnknownMapper)
    end
  end

  context 'with untyped mappings' do

    let(:mappings) do

      mappings = ROM::Mapper::Mapping::Registry.new

      mappings.register(Address) do
        map :id
        map :city
        map :zip
      end

      mappings.register(Task) do
        map :id
        map :name
      end

      mappings.register(Person) do
        map :id
        map :name

        wrap  :address, Address
        group :tasks,   Task
      end

      mappings

    end

    it_behaves_like 'mapping'
  end

  context 'with typed mappings' do

    let(:mappings) do

      mappings = ROM::Mapper::Mapping::Registry.new

      mappings.register(Address) do
        map :id,   Integer
        map :city, String
        map :zip,  Integer
      end

      mappings.register(Task) do
        map :id,   Integer
        map :name, String
      end

      mappings.register(Person) do
        map :id,   Integer
        map :name, String

        wrap  :address, Address
        group :tasks,   Task
      end

      mappings

    end

    it_behaves_like 'mapping'
  end

end
