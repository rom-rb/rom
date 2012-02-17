$LOAD_PATH << File.expand_path('../lib', __FILE__)

Dir.glob('spec/examples/**/*.rb').each { |file| require File.expand_path(file) }

require 'session'
require 'rspec'

class DummyMapper

  # Dumps an object into intermediate representation.
  # Two level hash, first level is collection, second the 
  # values for the entry.
  # So you can map to multiple collection entries.
  # Currently im only specing AR pattern in this test, 
  # but time will change!
  #
  def dump(object)
    { :domain_objects => dump_value(object) }
  end

  # Used internally
  def dump_value(object)
    {
      :key_attribute => object.key_attribute,
      :other_attribute => object.other_attribute
    }
  end

  # Loads an object from intermediate represenation.
  # Same format as dump but operation is reversed.
  # Construction of objects can be don in a ORM-Model component
  # specific subclass (Virtus?)
  #
  def load(model,dump)
    raise unless model == DomainObject
    values = dump.fetch(:domain_objects)

    DomainObject.new(
      values.fetch(:key_attribute),
      values.fetch(:other_attribute)
    )
  end

  # Dumps a key intermediate representation from object
  def dump_key(object)
    {
      :domain_objects => {
        :key_attribute => object.key_attribute
      }
    }
  end

  # Loads a key intermediate representation from dump
  def load_key(model,dump)
    raise unless model == DomainObject
    values = dump.fetch(:domain_objects)
    {
      :domain_objects => {
        :key_attribute => values.fetch(:key_attribute)
      }
    }
  end
end

# Dummy adapter that records interactions. 
# The idea is to support the most basic crud operations.
class DummyAdapter
  attr_reader :inserts,:deletes,:updates

  def initialize
    @deletes,@inserts,@updates = [],[],[]
  end

  # TODO: Some way to return generated keys?
  # @param [Symbol] collectio the collection where the record should be inserted
  # @param [Hash] the record to be inserted
  #
  def insert(collection,dump)
    @inserts << [collection,dump]
  end

  # @param [Symbol] collection the collection where the delete should happen
  # @param [Hash] delete_key the key identifying the record to delete
  #
  def delete(collection,delete_key)
    @deletes << [collection,delete_key]
  end

  # TODO: 4 params? Am I dump?
  # I need the old and the new record representation to generate some 
  # advanced mongo udpates.
  #
  # @param [Symbol] collection the collection where the update should happen
  # @param [Hash] update_key the key to update the record under
  # @param [Hash] new_record the updated record (all fields!)
  # @param [Hash] old_record the old record (all fields!)
  #
  def update(collection,update_key,new_record,old_record)
    @updates << [collection,update_key,new_record,old_record]
  end

  # Returns arrays of intermediate representations of matched models.
  # Adapters do not have to deal with creating model instances etc.
  #
  # @param [Object] query the query currently not specified...
  def read(query)
    query.call
  end
end

# The keylike behaviour of :key_attribute is defined by mapping. 
# The key_ prefix is only cosmetic here!
# Simple PORO, but could also be a virtus model, but I'd like to 
# make sure I do not couple to its API.
class DomainObject
  attr_accessor :key_attribute,:other_attribute
  def initialize(key_attribute=:a,other_attribute=:b)
    @key_attribute,@other_attribute = key_attribute,other_attribute
  end
end
