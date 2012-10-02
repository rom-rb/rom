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
  attr_accessor :key_attribute, :other_attribute
  def initialize(key_attribute=:a, other_attribute=:b)
    @key_attribute, @other_attribute = key_attribute,other_attribute
  end
end

# A test double for states
class DummyState
  include Equalizer.new(:mapping, :key, :dump)

  attr_reader :mapping, :key, :dump

  def initialize(mapping, key, dump)
    @mapping, @key, @dump = mapping, key, dump
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

  def wrap_query(*, &block)
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

  attr_reader :inserts, :deletes,:updates

  def initialize
    @deletes, @inserts,@updates = [],[],[]
  end

  # Insert 
  #
  # @param [State]
  #
  # @api private
  #
  def insert(state)
    @inserts << state
  end

  # Delete
  #
  # @param [STate] 
  #
  def delete(state)
    @deletes << state
  end

  # Update
  #
  # @param [State] new_state
  # @param [State] old_state
  #
  def update(new_state, old_state)
    @updates << [new_state, old_state]
  end
end

class DummyRegistry < Session::Registry
  def initialize
    super(DomainObject => DummyMapper.new)
  end
end
