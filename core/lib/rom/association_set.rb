# frozen_string_literal: true

require 'rom/registry'

module ROM
  # Association set contains a registry with associations defined
  # in schema DSL
  #
  # @api public
  class AssociationSet < ROM::Registry
    # @api private
    def initialize(...)
      super
      elements.values.each do |assoc|
        elements[assoc.name] = assoc if assoc.aliased? && !key?(assoc.name)
      end
    end
  end
end
