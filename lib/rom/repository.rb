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

    # @api public
    def command(type, relation)
      ast = relation.to_ast
      mapper = mappers[ast]
      adapter = __send__(relation.name).adapter

      CommandCompiler[container, type, adapter, ast] >> mapper
    end

    class Base < Repository
      def self.inherited(klass)
        super
        Deprecations.announce(self, 'inherit from Repository instead')
      end
    end
  end
end
