# frozen_string_literal: true

require "dry/core/class_attributes"
require "dry/core/cache"

require "rom/constants"
require "rom/initializer"

module ROM
  # Abstract Changeset class
  #
  # If you inherit from this class you need to configure additional settings
  #
  # @example define a custom changeset using :upsert command
  #   class NewTag < ROM::Changeset[:tags]
  #     command_type :upsert
  #   end
  #
  # @abstract
  class Changeset
    extend Initializer
    extend Dry::Core::Cache
    extend Dry::Core::ClassAttributes

    # @!method self.command_type
    #   Get or set changeset command type
    #
    #   @overload command_type
    #     Return configured command_type
    #     @return [Symbol]
    #
    #   @overload command_type(identifier)
    #     Set relation identifier for this changeset
    #     @param [Symbol] identifier The command type identifier
    #     @return [Symbol]
    defines :command_type

    # @!method self.command_options
    #   Get or set command options
    #
    #   @overload command_options
    #     Return configured command_options
    #     @return [Hash,nil]
    #
    #   @overload command_options(**options)
    #     Set command options
    #     @param options [Hash] The command options
    #     @return [Hash]
    defines :command_options

    # @!method self.command_plugins
    #   Get or set command plugins options
    #
    #   @overload command_plugins
    #     Return configured command_plugins
    #     @return [Hash,nil]
    #
    #   @overload command_plugins(**options)
    #     Set command plugin options
    #     @param options [Hash] The command plugin options
    #     @return [Hash]
    defines :command_plugins

    # @!method self.relation
    #   Get or set changeset relation identifier
    #
    #   @overload relation
    #     Return configured relation identifier for this changeset
    #     @return [Symbol]
    #
    #   @overload relation(identifier)
    #     Set relation identifier for this changeset
    #     @param [Symbol] identifier The relation identifier from the ROM container
    #     @return [Symbol]
    defines :relation

    # @!attribute [r] relation
    #   @return [Relation] The changeset relation
    param :relation

    # @!attribute [r] command_type
    #   @return [Symbol] a custom command identifier
    option :command_type, default: -> { self.class.command_type }

    # @!attribute [r] command_options
    #   @return [Hash] Configured options for the command
    option :command_options, default: -> { self.class.command_options }

    # @!attribute [r] command_plugins
    #   @return [Hash] Configured plugin options for the command
    option :command_plugins, default: -> { self.class.command_plugins }

    # Set the default command options
    command_options(mapper: false)

    # Set the default command plugin options
    command_plugins(EMPTY_HASH)

    # Create a changeset class preconfigured for a specific relation
    #
    # @example
    #   class NewUserChangeset < ROM::Changeset::Create[:users]
    #   end
    #
    #   users.changeset(NewUserChangeset).data(name: 'Jane')
    #
    # @api public
    def self.[](relation_name)
      fetch_or_store([relation_name, self]) {
        Class.new(self) { relation(relation_name) }
      }
    end

    # Enable a plugin for the changeset
    #
    # @api public
    def self.use(plugin, **options)
      ROM.plugin_registry[:changeset].fetch(plugin).apply_to(self, **options)
    end

    # Return a new changeset with provided relation
    #
    # New options can be provided too
    #
    # @param [Relation] relation
    # @param [Hash] new_options
    #
    # @return [Changeset]
    #
    # @api public
    def new(relation, **new_options)
      self.class.new(relation, **options, **new_options)
    end

    # Persist changeset
    #
    # @example
    #   changeset = users.changeset(name: 'Jane')
    #   changeset.commit
    #   # => { id: 1, name: 'Jane' }
    #
    # @return [Hash, Array]
    #
    # @api public
    def commit
      command.call
    end

    # Return string representation of the changeset
    #
    # @return [String]
    #
    # @api public
    def inspect
      %(#<#{self.class} relation=#{relation.name.inspect}>)
    end

    # Return a command for this changeset
    #
    # @return [ROM::Command]
    #
    # @api private
    def command
      relation.command(command_type, **command_compiler_options)
    end

    # Return configured command compiler options
    #
    # @return [Hash]
    #
    # @api private
    def command_compiler_options
      command_options.merge(use: command_plugins.keys, plugins_options: command_plugins)
    end
  end
end

require "rom/changeset/stateful"
require "rom/changeset/associated"

require "rom/changeset/create"
require "rom/changeset/update"
require "rom/changeset/delete"

require "rom/plugins"

ROM::Plugins.register(:changeset, adapter: false)
