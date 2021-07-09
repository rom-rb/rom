# frozen_string_literal: true

require "dry/effects"

require_relative "dsl"

module ROM
  # @api private
  module Components
    # @api private
    class Provider < Module
      attr_reader :provider

      attr_reader :types

      # @api private
      def initialize(types)
        @provider = nil
        @types = types
      end

      # @api private
      def included(provider)
        super
        @provider = provider
        provider.include(mod)
        provider.include(Components)
        freeze
      end

      # @api private
      def extended(provider)
        super
        @provider = provider
        provider.extend(mod)
        provider.extend(Components)
        freeze
      end

      # @api private
      def mod
        @mod ||=
          begin
            mod = Module.new {
              include Dry::Effects::Handler.Reader(:configuration)
            }

            define_dsl_method(mod, :__dsl__)

            types.each do |type|
              define_dsl_method(mod, type)
            end

            mod
          end
      end

      # @private
      def define_dsl_method(mod, name)
        mod.define_method(name) { |*args, **opts, &block|
          DSL.instance_method(name).bind(self).(*args, **opts, &block)
        }
      end
    end
  end
end
