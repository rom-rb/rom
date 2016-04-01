require 'rom/support/deprecations'
require 'rom/support/options'

require 'rom/repository/mapper_builder'
require 'rom/repository/loading_proxy'
require 'rom/repository/command_compiler'

module ROM
  # Abstract repository class to inherit from
  #
  # @api public
  class Repository
    # @deprecated
    class Base < Repository
      def self.inherited(klass)
        super
        Deprecations.announce(self, 'inherit from Repository instead')
      end
    end

    attr_reader :container

    attr_reader :mappers

    # Define which relations your repository is going to use
    #
    # @example
    #   class MyRepo < ROM::Repository::Base
    #     relations :users, :tasks
    #   end
    #
    #   my_repo = MyRepo.new(rom_env)
    #
    #   my_repo.users
    #   my_repo.tasks
    #
    # @return [Array<Symbol>]
    #
    # @api public
    def self.relations(*names)
      if names.any?
        attr_reader(*names)
        @relations = names
      else
        @relations
      end
    end

    # @api private
    def initialize(container)
      @container = container
      @mappers = MapperBuilder.new

      self.class.relations.each do |name|
        relation = container.relations[name]

        proxy = LoadingProxy.new(relation, name: name, mappers: mappers)

        instance_variable_set("@#{name}", proxy)
      end
    end

    # Create a command for a relation
    #
    # @example
    #   create_user = repo.command(:create, repo.users)
    #
    #   create_user_with_task = repo.command(:create, repo.users.combine_children(one: repo.tasks))
    #
    # @param [Symbol] type Type of the command
    # @param [Repository::LoadingProxy] relation
    #
    # @return [ROM::Command]
    #
    # @api public
    def command(*args)
      type, relation = args

      commands.fetch_or_store(args.hash) do
        ast = relation.to_ast
        adapter = __send__(relation.name).adapter

        CommandCompiler[container, type, adapter, ast] >> mappers[ast]
      end
    end

    private

    def commands
      @__commands__ ||= Concurrent::Map.new
    end
  end
end
