# frozen_string_literal: true

require "rom/command_compiler"
require "rom/container"

# temporary
require "rom/configuration_dsl/relation"

module ROM
  # This giant builds an container using defined classes for core parts of ROM
  #
  # It is used by the setup object after it's done gathering class definitions
  #
  # @private
  class Finalize
    attr_reader :configuration, :components, :notifications

    # @api private
    def initialize(configuration)
      # Ensure components are loaded through auto-registration
      @configuration = configuration.finalize

      @notifications = configuration.notifications
      @components = configuration.components
    end

    # Run the finalization process
    #
    # This creates relations, mappers and commands
    #
    # @return [Container]
    #
    # @api private
    def run!
      load_relations

      container = Container.new(configuration.gateways, relations)
      container.freeze
      container
    end

    # @api private
    def relations
      configuration.relations
    end

    private

    # Add relations to the registry
    #
    # @api private
    def load_relations
      components.relations.each do |component|
        relation = relations.add(component.id, component.build)

        notifications.trigger(
          "configuration.relations.object.registered",
          relation: relation, registry: relations
        )
      end

      # We need to finalize schema's associations here because they need
      # relations already registered
      relations.each_value do |relation|
        relation.schema.finalize_associations!(relations: relations).finalize!
      end

      notifications.trigger("configuration.relations.registry.created", registry: relations)
    end
  end
end
