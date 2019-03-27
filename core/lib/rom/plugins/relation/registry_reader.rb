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
      class RegistryReader < Module
        EMPTY_REGISTRY = RelationRegistry.new(EMPTY_HASH).freeze

        # @api private
        attr_reader :relations

        # @api private
        def initialize(relations)
          @relations = relations
          define_readers!
        end

        # @api private
        def included(klass)
          super
          return if klass.instance_methods.include?(:__registry__)
          klass.option :__registry__, default: -> { EMPTY_REGISTRY }
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
