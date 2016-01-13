require 'rom/support/deprecations'
require 'rom/support/options'

require 'rom/repository/mapper_builder'
require 'rom/repository/loading_proxy'
require 'rom/repository/command_compiler'

module ROM
  class Repository
    # Abstract repository class to inherit from
    #
    # TODO: rename this to Repository once deprecated Repository from rom core is gone
    #
    # @api public
    include Options

    attr_reader :container

    attr_reader :commands

    option :mapper_builder, reader: true, default: proc { MapperBuilder.new }

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
    def initialize(container, options = {})
      super

      @container = container
      @commands = Hash.new { |h, k| h[k] = {} }

      self.class.relations.each do |name|
        relation = container.relations[name]

        proxy = LoadingProxy.new(
          relation, name: name, mapper_builder: mapper_builder
        )

        instance_variable_set("@#{name}", proxy)

        commands[name][:create] = ROM::Commands::Create[proxy.adapter].build(
          relation, result: :one
        )
      end
    end

    # @api public
    def command(type, relation)
      ast = relation.to_ast
      mapper = mapper_builder[ast]
      adapter = __send__(relation.name).adapter

      CommandCompiler[commands, type, adapter, ast] >> mapper
    end

    class Base < Repository
      def self.inherited(klass)
        super
        Deprecations.announce(self, 'inherit from Repository instead')
      end
    end
  end
end
