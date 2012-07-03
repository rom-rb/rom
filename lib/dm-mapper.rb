require 'data_mapper/mapper_registry'
require 'data_mapper/relation_registry'

require 'data_mapper/mapper'
require 'data_mapper/mapper/veritas_mapper'

require 'data_mapper/mapper/attribute'
require 'data_mapper/mapper/attribute/primitive'
require 'data_mapper/mapper/attribute/mapper'
require 'data_mapper/mapper/attribute/collection'
require 'data_mapper/mapper/attribute_set'

require 'data_mapper/mapper/relationship'
require 'data_mapper/mapper/relationship/one_to_one'
require 'data_mapper/mapper/relationship/one_to_many'
require 'data_mapper/mapper/relationship/many_to_one'
require 'data_mapper/mapper/relationship/many_to_many'
require 'data_mapper/mapper/relationship_set'

require 'data_mapper/mapper/query'

require 'data_mapper/support/inflector/inflections'
require 'data_mapper/support/inflector/methods'
require 'data_mapper/support/inflections'

module DataMapper

  # @api public
  def self.[](model)
    mapper_registry[model]
  end

  # @api public
  def self.setup(name, uri)
    adapters[name.to_sym] = Veritas::Adapter::DataObjects.new(uri)
  end

  # @api public
  def self.adapters
    @adapters ||= {}
  end

  # @api public
  def self.mapper_registry
    @mapper_registry ||= MapperRegistry.new
  end

  # @api public
  def self.relation_registry
    @_relation_registry ||= RelationRegistry.new
  end

  # @api public
  #
  # TODO: implement handling of dependencies between mappers
  def self.finalize
    mappers = Mapper::VeritasMapper.descendants

    mappers.each { |mapper| mapper_registry << mapper.finalize if mapper.relation_name }
    mappers.each { |mapper| mapper.finalize_attributes }
    mappers.each { |mapper| mapper.finalize_relationships }

    self
  end

end # module DataMapper
