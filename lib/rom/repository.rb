require 'rom/support/deprecations'
require 'rom/support/options'

require 'rom/repository/class_interface'
require 'rom/repository/mapper_builder'
require 'rom/repository/relation_proxy'
require 'rom/repository/command_compiler'

require 'rom/repository/root'

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

    extend ClassInterface

    attr_reader :container

    attr_reader :relations

    attr_reader :mappers

    # @api private
    def initialize(container)
      @container = container
      @mappers = MapperBuilder.new
      @relations = RelationRegistry.new do |registry, relations|
        self.class.relations.each do |name|
          relation = container.relation(name)

          proxy = RelationProxy.new(
            relation, name: name, mappers: mappers, registry: registry
          )

          instance_variable_set("@#{name}", proxy)

          relations[name] = proxy
        end
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
    # @param [Repository::RelationProxy] relation
    #
    # @return [ROM::Command]
    #
    # @api public
    def command(*args, **opts, &block)
      all_args = args + opts.to_a.flatten

      if all_args.size > 1
        commands.fetch_or_store(all_args.hash) do
          compile_command(*args, **opts)
        end
      else
        container.command(*args, &block)
      end
    end

    private

    def commands
      @__commands__ ||= Concurrent::Map.new
    end

    def compile_command(*args, mapper: nil, use: nil, **opts)
      type, name = args + opts.to_a.flatten(1)

      relation = name.is_a?(Symbol) ? relations[name] : name

      ast = relation.to_ast
      adapter = relations[relation.name].adapter

      if mapper
        mapper_instance = container.mappers[relation.name.relation][mapper]
      else
        mapper_instance = mappers[ast]
      end

      CommandCompiler[container, type, adapter, ast, use] >> mapper_instance
    end
  end
end
