# frozen_string_literal: true

require "rom/initializer"
require "rom/commands/graph"
require "rom/command_proxy"
require "rom/resolver"

module ROM
  # Builds commands for relations.
  #
  # This class is used by repositories to automatically create commands for
  # their relations. This is used both by `Repository#command` method and
  # `commands` repository class macros.
  #
  # @api private
  class CommandCompiler
    extend Initializer

    # @!attribute [r] id
    #   @return [Symbol] The command resolver identifier
    option :id, optional: true

    # @!attribute [r] command_class
    #   @return [Symbol] The command command_class
    option :command_class, optional: true

    # @!attribute [r] resolver
    #   @return [Resolver]
    option :resolver, default: -> { Resolver.new }

    # @!attribute [r] plugins
    #   @return [Array<Symbol>] a list of optional plugins that will be enabled for commands
    option :plugins, optional: true, default: -> { EMPTY_HASH }

    # @!attribute [r] meta
    #   @return [Array<Symbol>] Meta data for a command
    option :meta, optional: true

    # @!attribute [r] cache
    #   @return [Cache] local cache instance
    option :cache, default: -> { Cache.new }

    # Return a specific command command_class for a given adapter and relation AST
    #
    # This class holds its own resolver where all generated commands are being
    # stored
    #
    # CommandProxy is returned for complex command graphs as they expect root
    # relation name to be present in the input, which we don't want to have
    # in repositories. It might be worth looking into removing this requirement
    # from rom core Command::Graph API.
    #
    # @overload [](id, adapter, ast, plugins, meta)
    #   @param id [Symbol] The command identifier
    #   @param adapter [Symbol] The adapter identifier
    #   @param ast [Array] The AST representation of a relation
    #   @param plugins [Array<Symbol>] A list of optional command plugins that should be used
    #   @param meta [Hash] Meta data for a command
    #
    #   @return [Command, CommandProxy]
    #
    # @api private
    def call(*args)
      cache.fetch_or_store(args.hash) do
        id, adapter, ast, plugins, plugins_options, meta = args

        component = resolver.components.get(:commands, id: id)

        command_class =
          if component
            component.constant
          else
            Command.adapter_namespace(adapter).const_get(Inflector.classify(id))
          end

        plugins_with_opts = Array(plugins)
          .map { |plugin| [plugin, plugins_options.fetch(plugin) { EMPTY_HASH }] }
          .to_h

        compiler = with(
          id: id,
          command_class: command_class,
          adapter: adapter,
          plugins: plugins_with_opts,
          meta: meta
        )

        graph_opts = compiler.visit(ast)
        command = ROM::Commands::Graph.build(resolver.root.commands, graph_opts)

        if command.graph?
          root = Inflector.singularize(command.name.relation).to_sym
          CommandProxy.new(command, root)
        elsif command.lazy?
          command.unwrap
        else
          command
        end
      end
    end
    alias_method :[], :call

    # @api private
    def visit(ast, *args)
      name, node = ast
      __send__(:"visit_#{name}", node, *args)
    end

    # @api private
    def relations
      resolver.root.relations
    end

    private

    # @api private
    def visit_relation(node, parent_relation = nil)
      name, header, rel_meta = node
      other = header.map { |attr| visit(attr, name) }.compact

      key = register_command(name, rel_meta, parent_relation)

      default_mapping =
        if rel_meta[:combine_command_class] == :many
          name
        else
          {Inflector.singularize(name).to_sym => name}
        end

      mapping =
        if parent_relation
          associations = relations[parent_relation].associations

          assoc = associations[rel_meta[:combine_name]]

          if assoc
            {assoc.key => assoc.target.name.to_sym}
          else
            default_mapping
          end
        else
          default_mapping
        end

      if other.empty?
        [mapping, key]
      else
        [mapping, [key, other]]
      end
    end

    # @api private
    def visit_attribute(*)
      nil
    end

    # Build a command object for a specific relation
    #
    # The command will be prepared for handling associations if it's a combined
    # relation. Additional plugins will be enabled if they are configured for
    # this compiler.
    #
    # @param [Symbol] rel_name A relation identifier from the container resolver
    # @param [Hash] rel_meta Meta information from relation AST
    # @param [Symbol] parent_relation Optional parent relation identifier
    #
    # @return [ROM::Command]
    #
    # @api private
    def register_command(rel_name, rel_meta, parent_relation = nil)
      options = {
        rel_name: rel_name,
        meta: meta,
        rel_meta: rel_meta,
        parent_relation: parent_relation,
        plugins: plugins
      }

      key = "commands.#{rel_name}.#{id}-compiled-#{options.hash}"

      resolver.fetch(key) do
        command_class
          .create_class(relation: relations[rel_name], **options)
          .build(relations[rel_name])
      end

      key
    end
  end
end
