# encoding: utf-8

require 'addressable/uri'

require 'rom/environment'
require 'rom/repository'
require 'rom/schema/builder'
require 'rom/relation/mapper_builder'

module ROM

  # The environment configures repositories and loads schema with relations
  #
  class Environment

    # Environment builder DSL
    #
    class Builder
      include Concord::Public.new(:repositories, :schema, :mappers)

      attr_reader :relations

      # @api private
      def self.call(config)
        repositories = config.each_with_object({}) { |(name, uri), hash|
          hash[name.to_sym] = Repository.build(name, Addressable::URI.parse(uri))
        }

        schema = Schema::Builder.new(repositories)
        mappers = Relation::MapperBuilder.new(schema)

        new(repositories, schema, mappers)
      end

      # @api private
      def initialize(*args)
        super
        @relations = {}
      end

      # @api private
      def schema(options = {}, &block)
        @schema.call(options, &block) if block
        @schema
      end

      # @api private
      def mapping(&block)
        mappers.call(&block)
      end

      # @api private
      def [](name)
        relations[name]
      end

      # @api private
      def []=(name, relation)
        relations[name] = relation
      end

      # @api private
      def finalize
        schema.automapped.each do |name, relation|
          mappers.automap(name, relation)
        end

        schema  = self.schema.finalize
        mappers = self.mappers.finalize

        mappers.each do |name, mapper|
          relations[name] = Relation.new(schema[name], mapper)
        end

        Environment.new(repositories, schema, relations, mappers)
      end

    end # Builder

  end # Environment
end # ROM
