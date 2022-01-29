# frozen_string_literal: true

require "rom/relation/name"

require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      # @api private
      option :name, type: Types.Instance(ROM::Relation::Name), default: -> {
        ROM::Relation::Name[config.relation, config.dataset]
      }

      # @api public
      def build
        if view?
          resolver.schemas[config.relation].instance_eval(&block)
        else
          schema = config.constant.define(name, **config, inferrer: inferrer, resolver: resolver)

          if gateway?
            schema.finalize_attributes!(gateway: gateway)
          else
            schema.finalize_attributes!
          end

          schema.finalize!
        end
      end

      # @api private
      def inferrer
        config.inferrer.with(enabled: config.infer)
      end

      # @api private
      def dataset
        config.dataset
      end

      # @api private
      def adapter
        config.adapter
      end

      # @api private
      def relation
        config.relation
      end

      # @api private
      def view?
        config.view.equal?(true)
      end
    end
  end
end
