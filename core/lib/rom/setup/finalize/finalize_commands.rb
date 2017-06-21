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
        commands_map = @command_classes.each_with_object({}) do |klass, h|
          rel_name = klass.relation
          next unless rel_name

          relation = @relations[rel_name]
          name = klass.register_as || klass.default_name

          gateway = @gateways[relation.class.gateway]

          notifications.trigger(
            'configuration.commands.class.before_build',
            command: klass, gateway: gateway, dataset: relation.dataset
          )

          klass.extend_for_relation(relation) if klass.restrictable

          (h[rel_name] ||= {})[name] = klass.build(relation)
        end

        registry = Registry.new({})
        compiler = CommandCompiler.new(@gateways, @relations, registry, notifications)

        commands = commands_map.each_with_object({}) do |(name, rel_commands), h|
          h[name] = CommandRegistry.new(rel_commands, relation_name: name, compiler: compiler)
        end

        @relations.each do |(name, relation)|
          unless commands.key?(name)
            commands[name] = CommandRegistry.new({}, relation_name: name, compiler: compiler)
          end
        end

        registry.elements.update(commands)

        registry
      end
    end
  end
end
