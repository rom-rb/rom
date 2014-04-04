# encoding: utf-8

require 'addressable/uri'

require 'rom/environment'
require 'rom/repository'
require 'rom/schema/builder'
require 'rom/mapper/builder'

module ROM

  # The environment configures repositories and loads schema with relations
  #
  class Environment

    # Environment builder DSL
    #
    class Builder
      attr_reader :repositories, :relations, :mappers

      # Build an environment instance from a repository config hash
      #
      # @example
      #
      #   config = { 'test' => 'memory://test' }
      #   env    = ROM::Environment.setup(config)
      #
      # @param [Environment, Hash<#to_sym, String>] config
      #   an environment or a hash of adapter uri strings,
      #   keyed by repository name
      #
      # @return [Environment]
      #
      # @api public
      def self.call(config)
        repositories = config.each_with_object({}) { |(name, uri), hash|
          hash[name.to_sym] = Repository.build(name, Addressable::URI.parse(uri))
        }

        new(repositories)
      end

      # Build a new environment
      #
      # @param [Hash] repositories
      #
      # @param [Hash] relations for relations
      #
      # @return [Environment]
      #
      # @api private
      def initialize(repositories)
        @repositories = repositories
        @relations = {}
        @schema = Schema::Builder.build(repositories)
        @mappers = Mapper::Builder.new(schema)
      end

      # Build a relation schema for this environment
      #
      # @example
      #   env = Environment.coerce(test: 'memory://test')
      #
      #   env.schema do
      #     base_relation :users do
      #       repository :test
      #
      #       attribute :id, Integer
      #       attribute :name, String
      #     end
      #   end
      #
      # @return [Schema]
      #
      # @api public
      def schema(&block)
        @schema.call(&block) if block
        @schema
      end

      # Define mapping for relations
      #
      # @example
      #
      #   env.schema do
      #     base_relation :users do
      #       repository :test
      #
      #       attribute :id,        Integer
      #       attribtue :user_name, String
      #     end
      #   end
      #
      #   env.mapping do
      #     users do
      #       model User
      #
      #       map :id
      #       map :user_name, :to => :name
      #     end
      #   end
      #
      # @return [Mapping]
      #
      # @api public
      def mapping(&block)
        mappers.call(&block)
      end

      # Return registered relation
      #
      # @example
      #
      #   env[:users]
      #
      # @param [Symbol] relation name
      #
      # @return [Relation]
      #
      # @api public
      def [](name)
        relations[name]
      end

      # Register a rom relation
      #
      # @return [Environment]
      #
      # @api private
      def []=(name, relation)
        relations[name] = relation
      end

      # @api public
      def finalize
        mappers.each do |name, mapper|
          relations[name] = Relation.new(schema[name], mapper)
        end

        Environment.new(repositories, schema.finalize, relations, mappers.finalize)
      end

    end # Builder

  end # Environment
end # ROM
