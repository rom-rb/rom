# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    module DSL
      # @api private
      class View < Core
        key :views

        # @api private
        attr_reader :schema_block

        # @api private
        attr_reader :relation_block

        # @see Components::DSL#view
        #
        # @api public
        def schema(&block)
          @schema_block = block
          self
        end

        # @see Components::DSL#view
        #
        # @api public
        def relation(&block)
          @relation_block = block
          self
        end

        # @api private
        def call
          # Nest view under relation ns
          config.join!({namespace: relation_id}, :right)

          if args.empty? && block.arity.positive?
            raise ArgumentError, "schema attribute names must be provided as the second argument"
          end

          # Capture schema and relation blocks if there are no args
          # otherwise assume args is a list of attributes to project
          if args.empty? && block
            instance_eval(&block)
          else
            schema { schema.project(*args.first) }
          end

          provider.schema(
            id: config.id,
            namespace: relation_id,
            relation: relation_id,
            view: true,
            &schema_block
          )

          components.add(
            key,
            config: config,
            relation_id: relation_id,
            # Default to the block because we assume the schema was set based on args
            relation_block: relation_block || block
          )
        end

        private

        # @api private
        def args
          config.args
        end

        # @api private
        def relation_id
          provider.config.component.id
        end
      end
    end
  end
end
