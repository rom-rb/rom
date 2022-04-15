# frozen_string_literal: true

require "rom/components/core"
require "rom/components/dataset"
require "rom/components/relation"
require "rom/components/command"

module ROM
  class Components::Core
    # @api private
    def trigger(event, payload)
      registry.trigger("configuration.#{event}", payload)
    end

    # @api private
    def notifications
      registry.notifications
    end
  end

  class Components::Dataset < Components::Core
    mod = Module.new do
      # @api private
      def evaluate_block(ds, block)
        if block.parameters.flatten.include?(:schema)
          super
        else
          ds.instance_exec(relation_constant, &block)
        end
      end

      def relation_constant
        registry.components.get(:relations, id: relation_id).constant
      end
    end

    prepend(mod)
  end

  class Components::Relation < Components::Core
    mod = Module.new do
      def build
        schema = local_components.get(:schemas, id: id)&.build

        if schema
          trigger(
            "relations.schema.set",
            schema: schema,
            adapter: adapter,
            gateway: config[:gateway],
            relation: constant,
            registry: registry
          )
        end

        trigger("relations.class.ready", relation: constant, adapter: adapter)

        components.update(local_components)

        relation = super

        trigger("relations.object.registered", registry: registry, relation: relation)

        relation
      end
    end

    prepend(mod)
  end

  class Components::Command < Components::Core
    mod = Module.new do
      def build
        relation = registry.relations[config.relation]

        trigger(
          "commands.class.before_build",
          command: constant,
          gateway: registry.gateways[relation.gateway],
          dataset: relation.dataset,
          relation: relation,
          adapter: adapter
        )

        super
      end
    end

    prepend(mod)
  end
end
