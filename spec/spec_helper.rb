begin
  require 'rspec'  # try for RSpec 2
rescue LoadError
  require 'spec'   # try for RSpec 1
  RSpec = Spec::Runner
end

$LOAD_PATH << File.expand_path('../lib', __FILE__)

Dir.glob('spec/examples/**/*.rb').each { |file| require File.expand_path(file) }
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }

require 'session'
require 'session/registry'

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

# A test double for a mapper that records commands.
class DummyMapper
  def dump(object)
    {
      :key_attribute => object.key_attribute,
      :other_attribute => object.other_attribute
    }
  end

  def dumps=(dumps)
    @dumps = dumps
  end

  def dumps
    @dumps || raise('no stored dumps')
  end

  def wrap_query(*,&block)
    dumps.map do |dump|
      block.call(dump)
    end
  end

  # Loads an object from intermediate represenation.
  # Same format as dump but operation is reversed.
  # Construction of objects can be don in a ORM-Model component
  # specific subclass (Virtus?)
  #
  def load(dump)
    DomainObject.new(
      dump.fetch(:key_attribute),
      dump.fetch(:other_attribute)
    )
  end

  # Dumps a key intermediate representation from object
  def dump_key(object)
    object.key_attribute
  end

  # Loads a key intermediate representation from dump
  def load_key(dump)
    dump.fetch(:key_attribute)
  end

  attr_reader :inserts,:deletes,:updates

  def initialize
    @deletes,@inserts,@updates = [],[],[]
  end

  # Inserting an object
  #
  # @param [Object] the object to be inserted
  #
  def insert_object(object)
    insert_dump(dump(object))
  end

  # Inserting a dump
  #
  # @param [Hash] the dump to be inserted
  def insert_dump(dump)
    @inserts << dump
  end

  # @param [Hash] key the key identifying the record to delete
  #
  def delete(key)
    @deletes << key
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
end

class DummyRegistry < Session::Registry
  def initialize(*)
    super
    register(DomainObject,DummyMapper.new)
  end
end
