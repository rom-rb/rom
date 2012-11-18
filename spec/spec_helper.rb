require 'rspec'

$LOAD_PATH << File.expand_path('../lib', __FILE__)

Dir.glob('spec/examples/**/*.rb').each { |file| require File.expand_path(file) }
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }

require 'dm-session'

class Spec
  class DomainObject
    attr_accessor :key_attribute, :other_attribute
    def initialize(key_attribute=:a, other_attribute=:b)
      @key_attribute, @other_attribute = key_attribute,other_attribute
    end
  end

  # A test double for states
  class State
    include Equalizer.new(:mapping, :key, :dump)

    attr_reader :mapping, :key, :dump

    def initialize(mapping, key, dump)
      @mapping, @key, @dump = mapping, key, dump
    end
  end

  # A test double for a dumper
  class Dumper
    include Equalizer.new(:key, :body)

    def initialize(object)
      @object = object
    end

    def body
      {
        :key_attribute => @object.key_attribute, 
        :other_attribute => @object.other_attribute
      }
    end

    def key
      @object.key_attribute
    end
  end

  # A test double for a loader
  class Loader
    include Equalizer.new(:key, :object)

    def initialize(dump)
      @dump = dump
    end

    def body
      DomainObject.new(
        @dump.fetch(:key_attribute), 
        @dump.fetch(:other_attribute)
      )
    end

    def key
      dump.fetch(:key_attribute)
    end
  end

  # A test double for a mapper that records commands.
  class Mapper
    include Equalizer.new(:dumps, :inserts, :updates, :deletes)

    def dumps=(dumps)
      @dumps = dumps
    end

    attr_reader :inserts, :deletes, :updates, :dumps

    def initialize
      @deletes, @inserts, @updates = [], [], []
    end

    def loader(dump)
      Loader.new(dump)
    end

    def dumper(object)
      Dumper.new(object)
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
