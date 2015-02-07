require 'rom/setup/finalize'

module ROM
  # Exposes DSL for defining relations, mappers and commands
  #
  # @public
  class Setup
    include Equalizer.new(:repositories, :env)

    # @api private
    attr_reader :repositories, :default_adapter, :env

    # @api private
    def initialize(repositories, default_adapter = nil)
      @repositories = repositories
      @default_adapter = default_adapter
      @relation_classes = {}
      @env = nil
    end

    # @api public
    def register_relation(klass)
      name = klass.register_as

      if @relation_classes.key?(name)
        raise(
          RelationAlreadyDefinedError,
          "Relation with `register_as #{name.inspect}` registered more " \
          "than once"
        )
      end

      @relation_classes[name] = klass
    end

    # Finalize the setup
    #
    # @return [Env] frozen env with access to repositories, relations,
    #                mappers and commands
    #
    # @api public
    def finalize
      raise EnvAlreadyFinalizedError if env

      @env = Finalize.new(
        repositories: repositories,
        relation_classes: @relation_classes
      ).run!
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
