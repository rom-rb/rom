# encoding: utf-8

module ROM

  # ROM's relation schema
  #
  class Schema
    include Concord.new(:relations), Adamantium::Flat

    # Return a relation identified by name
    #
    # @param [Symbol] name of the relation
    #
    # @return [Relation]
    def [](name)
      relations[name]
    end

  end # Schema

end # ROM
