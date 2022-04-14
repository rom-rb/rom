# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Relation < Core
      # @!attribute [r] constant
      #   @return [.new] Relation instance builder (typically a class)
      option :constant, type: Types.Interface(:new)

      # @return [ROM::Relation]
      #
      # @api public
      def build
        constant.use(:changeset)
        constant.use(:registry_reader, relations: registry.relation_ids)

        # Define view methods if there are any registered view components for this relation
        local_components.views(relation_id: id).each do |view|
          view.define(constant)
        end

        apply_plugins

        constant.new(inflector: inflector, registry: registry, **plugin_options)
      end

      # @api public
      def adapter
        config.adapter
      end

      # @api private
      def local_components
        constant.components
      end
    end
  end
end
