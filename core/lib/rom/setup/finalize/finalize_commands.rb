# frozen_string_literal: true

require 'rom/registry'
require 'rom/command_compiler'
require 'rom/command_registry'

module ROM
  class Finalize
    class FinalizeCommands
      attr_reader :notifications

      # Build command registry hash for provided relations
      #
      # @param [RelationRegistry] relations registry
      # @param [Hash] gateways
      # @param [Array] command_classes a list of command subclasses
      #
      # @api private
      def initialize(relations, gateways, command_classes, notifications)
        @relations = relations
        @gateways = gateways
        @command_classes = command_classes
        @notifications = notifications
      end

      # @return [Hash]
      #
      # @api private
      def run!
        commands = @command_classes.map do |klass|
          relation = @relations[klass.relation]
          gateway = @gateways[relation.gateway]

          notifications.trigger(
            'configuration.commands.class.before_build',
            command: klass, gateway: gateway, dataset: relation.dataset, adapter: relation.adapter
          )

          klass.extend_for_relation(relation) if klass.restrictable

          klass.build(relation)
        end

        registry = Registry.new({})
        compiler = CommandCompiler.new(@gateways, @relations, registry, notifications)

        @relations.each do |(name, relation)|
          commands.
            select { |c| c.relation.name == relation.name }.
            each { |c| relation.commands.elements[c.class.register_as || c.class.default_name] = c }

          relation.commands.set_compiler(compiler)
          relation.commands.set_mappers(relation.mappers)

          registry.elements[name] = relation.commands
        end

        registry
      end
    end
  end
end
