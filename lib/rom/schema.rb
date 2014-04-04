# encoding: utf-8

require 'rom/schema/builder'
require 'rom/schema/definition'
require 'rom/schema/definition/relation'
require 'rom/schema/definition/relation/base'

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
      relations.fetch(name)
    end

  end # Schema

end # ROM
