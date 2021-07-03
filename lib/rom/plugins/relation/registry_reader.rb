# frozen_string_literal: true

require "rom/constants"
require "rom/runtime/resolver"

module ROM
  module Plugins
    module Relation
      # Allows relations to access all other relations through registry
      #
      # For now this plugin is always enabled
      #
      # @api public
      class RegistryReader < ::Module
        EMPTY_REGISTRY = EMPTY_HASH

        # @api private
        attr_reader :relations

        # @api private
        def initialize(relations:)
          @relations = relations
          define_readers!
        end

        # @api private
        def included(klass)
          super
          return if klass.instance_methods.include?(:__registry__)

          klass.option :__registry__, default: -> { Runtime::Resolver.new(:relations) }
        end

        private

        # @api private
        def define_readers!
          relations.each do |name|
            define_method(name) { __registry__[name] }
          end
        end
      end
    end
  end
end
