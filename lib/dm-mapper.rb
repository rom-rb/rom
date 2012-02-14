require 'data_mapper/relation_registry'
require 'data_mapper/mapper'
require 'data_mapper/mapper/veritas_mapper'
require 'data_mapper/mapper/attribute_set'
require 'data_mapper/mapper/attribute_set/attribute'

module DataMapper

  # @api public
  def self.relation_registry
    @_relation_registry ||= RelationRegistry.new
  end

end # module DataMapper
