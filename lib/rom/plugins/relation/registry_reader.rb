# frozen_string_literal: true

require "rom/constants"

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

        private

        # @api private
        def define_readers!
          relations.each do |name|
            define_method(name) { resolver.relations[name] }
          end
        end
      end
    end
  end
end
