# frozen_string_literal: true

require "rom/constants"
require "rom/registry"

module ROM
  # @api private
  class RelationRegistry < Registry
    # @api private
    def self.element_not_found_error
      RelationMissingError
    end

    # @api private
    def self.element_already_defined_error
      RelationAlreadyDefinedError
    end

    # @api private
    def initialize(elements = {}, **options)
      super
      yield(self, elements) if block_given?
    end

    # @api private
    def to_mapper_registry
      Registry.new(elements.map { |key, relation| [key, relation.mappers] }.to_h)
    end

    # @api private
    def to_command_registry
      Registry.new(elements.map { |key, relation| [key, relation.commands] }.to_h)
    end
  end
end
