# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      id :schema

      # @!attribute [r] proc
      #   @return [Class] A proc for evaluation via schema DSL
      #   @api public
      option :proc, type: Types.Interface(:call)

      # @!attribute [r] relation
      #   @return [Class] A relation class
      #   @api public
      option :relation, type: Types.Instance(Class)

      # @api public
      def build
        plugins = self.plugins

        schema = proc.call do
          # This is evaluated using Schema::DSL where app_plugin is defined
          plugins.each { |plugin| app_plugin(plugin) }
        end

        payload = {
          schema: schema,
          adapter: adapter,
          gateway: gateway,
          relation: relation,
          registry: relations
        }

        trigger("relations.schema.allocated", payload)

        # TODO: it would be great if we could remove setting schemas as a class ivar
        relation.set_schema!(schema)

        trigger("relations.schema.set", payload)

        schema
      end

      # @api private
      def call(**opts)
        proc.call(**opts)
      end
    end
  end
end
