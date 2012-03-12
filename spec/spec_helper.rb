$LOAD_PATH << File.expand_path('../lib', __FILE__)

Dir.glob('spec/examples/**/*.rb').each { |file| require File.expand_path(file) }
Dir.glob('spec/**/*_shared.rb').each { |file| require File.expand_path(file) }

require 'session'
require 'rspec'

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

# This could be some kind of adapter to dm-mapper
class DummyMapperRoot
  def initialize(mapper)
    @mapper = mapper
  end

  def delete_object_key(object,key)
    mapper_for_object(object).delete(object,key)
  end

  def update_object(object,old_key,old_dump)
    mapper_for_object(object).update(object,old_key,old_dump)
  end

  def insert_object(object)
    mapper_for_object(object).insert(object)
  end

  def dump(object)
    mapper_for_object(object).dump(object)
  end

  def dump_key(object)
    mapper_for_object(object).dump_key(object)
  end

  def load_object_key(object,dump)
    mapper_for_object(object).load_key(dump)
  end

  def mapper_for_model(model)
    raise unless model == DomainObject
    @mapper
  end

  def mapper_for_object(object)
    raise unless object.class == DomainObject
    @mapper
  end
end


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
  def load_key(dump)
    values = dump.fetch(:domain_objects)
    {
      :domain_objects => {
        :key_attribute => values.fetch(:key_attribute)
      }
    }
  end

  attr_reader :inserts,:deletes,:updates

  def initialize
    @deletes,@inserts,@updates = [],[],[]
  end

  # TODO: Some way to return generated keys?
  # @param [Symbol] collectio the collection where the record should be inserted
  # @param [Hash] the record to be inserted
  #
  def insert(object)
    @inserts << object
  end

  # @param [Symbol] collection the collection where the delete should happen
  # @param [Hash] delete_key the key identifying the record to delete
  #
  def delete(object,key)
    @deletes << [object,key]
  end

  # The old and the new dump can be used to generate nice updates.
  # Especially useful for advanced mongo udpates.
  #
  # @param [Symbol] collection the collection where the update should happen
  # @param [Hash] update_key the key to update the record under
  # @param [Hash] new_record the updated record (all fields!)
  # @param [Hash] old_record the old record (all fields!)
  #
  def update(key,object,old_dump)
    @updates << [key,object,old_dump]
  end

  # Returns arrays of intermediate representations of matched models.
  # Adapters do not have to deal with creating model instances etc.
  #
  # @param [Object] query the query currently not specified...
  def read(query)
    query.call
  end
end

