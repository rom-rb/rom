# frozen_string_literal: true

require 'rom/constants'

module ROM
  module Plugins
    module Relation
      # Allows relations to access all other relations through registry
      #
      # For now this plugin is always enabled
      #
      # @api public
      class RegistryReader < ::Module
        EMPTY_REGISTRY = RelationRegistry.build(EMPTY_HASH).freeze

        # @api private
        def initialize(klass:, relation_readers_module:)
          klass.include relation_readers_module
        end

        # @api private
        def included(klass)
          super
          return if klass.instance_methods.include?(:__registry__)

          klass.option :__registry__, default: -> { EMPTY_REGISTRY }
        end
      end
    end
  end
end
