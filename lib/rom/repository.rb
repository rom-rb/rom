require 'rom/support/deprecations'
require 'rom/support/options'

require 'rom/repository/mapper_builder'
require 'rom/repository/relation_proxy'
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

    extend ClassMacros

    defines :root

    attr_reader :container

    attr_reader :mappers

    attr_reader :root

    # @api public
    def self.[](name)
      klass = Class.new(self)
      klass.relations(name)
      klass.root(name)
      klass
    end

    # @api private
    def self.inherited(klass)
      super

      return if self === Repository

      klass.root(root)
      klass.relations(*relations)
      klass.commands(*commands)
    end

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

        if defined?(@relations)
          @relations.concat(names)
        else
          @relations = names
        end
      else
        @relations
      end
    end

    # @api public
    def self.commands(*names, **opts)
      if names.any?
        @commands = names + opts.to_a

        @commands.each do |spec|
          type, view = Array(spec).flatten

          if view
            define_method(type) do |*args|
              view_args, *input = args

              command(type => self.class.root)
                .public_send(view, *view_args)
                .call(*input)
            end
          else
            define_method(type) do |*args|
              command(type => self.class.root).call(*args)
            end
          end
        end
      else
        @commands || []
      end
    end

    # @api private
    def initialize(container)
      @container = container
      @mappers = MapperBuilder.new

      self.class.relations.each do |name|
        relation = container.relation(name)

        proxy = RelationProxy.new(relation, name: name, mappers: mappers)

        instance_variable_set("@#{name}", proxy)
      end

      # TODO: we should have a special subclass for repos with a root set
      @root = __send__(self.class.root) if self.class.root
    end

    # @api public
    def aggregate(options)
      root.combine_children(options)
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
        type, name = all_args
        relation = name.is_a?(Symbol) ? __send__(name) : name

        commands.fetch_or_store(all_args.hash) do
          ast = relation.to_ast
          adapter = __send__(relation.name).adapter

          CommandCompiler[container, type, adapter, ast] >> mappers[ast]
        end
      else
        container.command(*args, &block)
      end
    end

    private

    def commands
      @__commands__ ||= Concurrent::Map.new
    end
  end
end
