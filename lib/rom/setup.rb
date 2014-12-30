require 'rom/setup/schema_dsl'
require 'rom/setup/mapper_dsl'
require 'rom/setup/command_dsl'

require 'rom/setup/finalize'

module ROM
  # Exposes DSL for defining schema, relations and mappers
  #
  # @api public
  class Setup
    include Equalizer.new(:repositories, :env)

    attr_reader :repositories, :env

    # @api private
    def initialize(repositories)
      @repositories = repositories
      @schema = {}
      @relations = {}
      @mappers = []
      @commands = {}
      @adapter_relation_map = {}
      @env = nil
    end

    # Schema definition DSL
    #
    # @example
    #
    #   setup.schema do
    #     base_relation(:users) do
    #       repository :sqlite
    #
    #       attribute :id
    #       attribute :name
    #     end
    #   end
    #
    # @api public
    def schema(&block)
      dsl = SchemaDSL.new(self, @schema, &block)
      dsl.schema.each do |repo, relations|
        (@schema[repo] ||= []).concat(relations)
      end
      self
    end

    # Relation definition DSL
    #
    # @example
    #
    #   setup.relation(:users) do
    #     def names
    #       project(:name)
    #     end
    #   end
    #
    # @api public
    def relation(name, &block)
      @relations.update(name => block)
      self
    end

    # Mapper definition DSL
    #
    # @example
    #
    #   setup.mappers do
    #     define(:users) do
    #       model name: 'User'
    #     end
    #
    #     define(:names, parent: :users) do
    #       exclude :id
    #     end
    #   end
    #
    # @api public
    def mappers(&block)
      dsl = MapperDSL.new(&block)
      @mappers.concat(dsl.mappers)
      self
    end

    def commands(name, &block)
      dsl = CommandDSL.new(&block)
      @commands.update(name => dsl.commands)
    end

    # Finalize the setup
    #
    # @return [Env] frozen env with access to repositories, schema, relations
    #               and mappers
    #
    # @api public
    def finalize
      raise EnvAlreadyFinalizedError if env

      finalize = Finalize.new(
        repositories, @schema, @relations, @mappers, @commands
      )

      @env = finalize.run!
    end

    # @api private
    def [](name)
      repositories.fetch(name)
    end

    # @api private
    def respond_to_missing?(name, _include_context = false)
      repositories.key?(name)
    end

    private

    # @api private
    def method_missing(name, *_args)
      repositories.fetch(name)
    end
  end
end
