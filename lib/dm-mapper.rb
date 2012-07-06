require 'data_mapper/mapper_registry'
require 'data_mapper/relation_registry'
require 'data_mapper/gateway_registry'

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
  def self.setup_relation(name, header)
    relation_registry << Veritas::Relation::Base.new(name, header)
    self
  end

  # @api public
  def self.setup_gateway(repository, relation_name)
    adapter  = adapters[repository]
    relation = relation_registry[relation_name]
    gateway_registry << Veritas::Relation::Gateway.new(adapter, relation)
    self
  end

  # @api public
  def self.setup_relation_gateway(repository, name, header)
    setup_relation(name, header).setup_gateway(repository, name)
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
  def self.gateway_registry
    @_gateway_registry ||= GatewayRegistry.new
  end

  # @api public
  #
  # TODO: implement handling of dependencies between mappers
  def self.finalize
    mappers = Mapper::VeritasMapper.descendants

    mappers.each do |mapper_class|
      if mapper_class.relation_name
        mapper_class.finalize

        relation_name = mapper_class.relation_name
        repository    = mapper_class.repository

        setup_gateway(repository, relation_name)

        mapper_registry << mapper_class.new(gateway_registry[relation_name])
      end
    end

    mappers.each { |mapper| mapper.finalize_attributes }
    mappers.each { |mapper| mapper.finalize_relationships }

    self
  end

end # module DataMapper
