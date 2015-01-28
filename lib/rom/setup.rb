require 'rom/setup/mapper_dsl'
require 'rom/setup/command_dsl'

require 'rom/setup/finalize'

module ROM
  # Exposes DSL for defining relations, mappers and commands
  #
  # @public
  class Setup
    include Equalizer.new(:repositories, :env)

    # @api private
    attr_reader :repositories, :env

    # @api private
    def initialize(repositories)
      @repositories = repositories
      @relations = {}
      @env = nil
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
    def relation(name, options = {}, &block)
      if @relations.key?(name)
        raise RelationAlreadyDefinedError, "#{name.inspect} is already defined"
      end

      klass = Relation.build_class(name, options)

      repository = repositories[klass.repository]
      repository.extend_relation_class(klass)

      klass.class_eval(&block) if block

      @relations[name] = klass
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
      MapperDSL.new(&block)
    end

    # Command definition DSL
    #
    # @example
    #
    #   setup.commands(:users) do
    #     define(:create) do
    #       input NewUserParams
    #       validator NewUserValidator
    #       result :one
    #     end
    #
    #     define(:update) do
    #       input UserParams
    #       validator UserValidator
    #       result :many
    #     end
    #
    #     define(:delete) do
    #       result :many
    #     end
    #   end
    #
    # @api public
    def commands(name, &block)
      CommandDSL.new(name, &block)
    end

    # Finalize the setup
    #
    # @return [Env] frozen env with access to repositories, relations,
    #                mappers and commands
    #
    # @api public
    def finalize
      raise EnvAlreadyFinalizedError if env
      finalize = Finalize.new(repositories)
      @env = finalize.run!
    end

    # Returns repository identified by name
    #
    # @return [Repository]
    #
    # @api private
    def [](name)
      repositories.fetch(name)
    end

    # Hook for respond_to? used internally
    #
    # @api private
    def respond_to_missing?(name, _include_context = false)
      repositories.key?(name)
    end

    private

    # Returns repository if method is a name of a registered repository
    #
    # @return [Repository]
    #
    # @api private
    def method_missing(name, *)
      repositories.fetch(name) { super }
    end
  end
end
