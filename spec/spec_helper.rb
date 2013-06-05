require 'devtools'
require 'rom-session'

Devtools.init_spec_helper

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

    attr_reader :mapper 
    attr_reader :tuple 

    def initialize(mapper, tuple)
      @mapper, @tuple = mapper, tuple
    end

    def object
      @object ||= DomainObject.new(
        tuple.fetch(:key_attribute), 
        tuple.fetch(:other_attribute)
      )
    end

    def identity
      tuple.fetch(:key_attribute)
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

    # Return loader for tuple
    #
    # @param [Tuple] tuple
    #
    # @return [Loader]
    #
    # @api private
    #
    def loader(tuple)
      Loader.new(self, tuple)
    end

    # Return dumper for object
    #
    # @param [Object] object
    #
    # @return [Dumper]
    #
    # @api private
    #
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
    # @param [ROM::Operand::Update] operand
    #
    def update(operand)
      @updates << operand
    end
  end

  class Registry < ROM::Session::Registry
    def initialize
      super(DomainObject => Mapper.new)
    end
  end
end
