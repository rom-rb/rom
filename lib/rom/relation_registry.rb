# frozen_string_literal: true

require "rom/registry"

module ROM
  # @api private
  class RelationRegistry < Registry
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

    # @api private
    def add(key, relation)
      elements[key] = relation
    end
  end
end
