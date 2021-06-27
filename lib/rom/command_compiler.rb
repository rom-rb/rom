# frozen_string_literal: true

require "rom/support/inflector"

require "rom/initializer"
require "rom/commands"
require "rom/command_proxy"

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

    # @api private
    def self.registry
      Hash.new { |h, k| h[k] = {} }
    end

    # @!attribute [r] relations
    #   @return [ROM::RelationRegistry] Relations used with a given compiler
    option :relations

    # @!attribute [r] commands
    #   @return [ROM::Registry] Command registries with custom commands
    option :commands, default: -> { Registry.new }

    # @!attribute [r] id
    #   @return [Symbol] The command registry identifier
    option :id, optional: true

    # @!attribute [r] command_class
    #   @return [Symbol] The command command_class
    option :command_class, optional: true

    # @!attribute [r] registry
    #   @return [Hash] local registry where commands will be stored during compilation
    option :registry, optional: true, default: -> { self.class.registry }

    # @!attribute [r] plugins
    #   @return [Array<Symbol>] a list of optional plugins that will be enabled for commands
    option :plugins, optional: true, default: -> { EMPTY_ARRAY }

    # @!attribute [r] plugins_options
    #   @return [Hash] a hash of options for the plugins
    option :plugins_options, optional: true, default: -> { EMPTY_HASH }

    # @!attribute [r] meta
    #   @return [Array<Symbol>] Meta data for a command
    option :meta, optional: true

    # @!attribute [r] cache
    #   @return [Cache] local cache instance
    option :cache, default: -> { Cache.new }

    # @!attribute [r] inflector
    #   @return [Dry::Inflector] String inflector
    #   @api private
    option :inflector, default: -> { Inflector }

    # Return a specific command command_class for a given adapter and relation AST
    #
    # This class holds its own registry where all generated commands are being
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

        command_class = Command.adapter_namespace(adapter).const_get(inflector.classify(id))

        compiler = with(
          id: id,
          command_class: command_class,
          adapter: adapter,
          plugins: Array(plugins),
          plugins_options: plugins_options,
          meta: meta
        )

        graph_opts = compiler.visit(ast)
        command = ROM::Commands::Graph.build(registry, graph_opts)

        if command.graph?
          root = inflector.singularize(command.name.relation).to_sym
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

    private

    # @api private
    def visit_relation(node, parent_relation = nil)
      name, header, meta = node
      other = header.map { |attr| visit(attr, name) }.compact

      register_command(name, command_class, meta, parent_relation)

      default_mapping =
        if meta[:combine_command_class] == :many
          name
        else
          {inflector.singularize(name).to_sym => name}
        end

      mapping =
        if parent_relation
          associations = relations[parent_relation].associations

          assoc = associations[meta[:combine_name]]

          if assoc
            {assoc.key => assoc.target.name.to_sym}
          else
            default_mapping
          end
        else
          default_mapping
        end

      if other.empty?
        [mapping, command_class]
      else
        [mapping, [command_class, other]]
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
    # @param [Symbol] rel_name A relation identifier from the container registry
    # @param [Symbol] command_class The command command_class
    # @param [Hash] rel_meta Meta information from relation AST
    # @param [Symbol] parent_relation Optional parent relation identifier
    #
    # @return [ROM::Command]
    #
    # @api private
    def register_command(rel_name, command_class, rel_meta, parent_relation = nil)
      relation = relations[rel_name]

      klass = command_class.create_class(
        relation: relation,
        meta: meta,
        rel_meta: rel_meta,
        parent_relation: parent_relation,
        plugins: plugins,
        plugins_options: plugins_options,
        inflector: inflector
      )

      registry[rel_name][command_class] = klass.build(relation)
    end
  end
end
