require 'rspec'

$LOAD_PATH << File.expand_path('../lib', __FILE__)

Dir.glob('spec/examples/**/*.rb').each { |file| require File.expand_path(file) }
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }

require 'dm-session'

class Spec
  class DomainObject
    #include Equalizer.new(:key_attribute, :other_attribute)

    attr_accessor :key_attribute, :other_attribute
    def initialize(key_attribute=:a, other_attribute=:b)
      @key_attribute, @other_attribute = key_attribute,other_attribute
    end
  end

  # A test double for a dumper
  class Dumper
    include Equalizer.new(:identity, :tuple)

    def initialize(object)
      @object = object
    end

    def tuple
      {
        :key_attribute => @object.key_attribute, 
        :other_attribute => @object.other_attribute
      }
    end

    def identity
      @object.key_attribute
    end

  end

  # A test double for a loader
  class Loader
    include Equalizer.new(:identity, :tuple)

    attr_reader :tuple 

    def initialize(tuple)
      @tuple = tuple
    end

    def object
      DomainObject.new(
        tuple.fetch(:key_attribute), 
        tuple.fetch(:other_attribute)
      )
    end

    def identity
      @raw.fetch(:key_attribute)
    end
  end

  # A test double for a mapper that records commands.
  class Mapper
    include Equalizer.new(:tuples, :inserts, :updates, :deletes)

    def tuples=(tuples)
      @tuples = tuples
    end

    attr_reader :inserts, :deletes, :updates, :tuples

    def initialize
      @deletes, @inserts, @updates = [], [], []
    end

    def model
      DomainObject
    end

    def loader(tuple)
      Loader.new(tuple)
    end

    def dumper(object)
      Dumper.new(object)
    end

    def identity(object)
      object.key_attribute
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

  class Registry < DataMapper::Session::Registry
    def initialize
      super(DomainObject => Mapper.new)
    end
  end
end
