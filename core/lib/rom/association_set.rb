# frozen_string_literal: true

require 'rom/registry'

module ROM
  # Association set contains a registry with associations defined
  # in schema DSL
  #
  # @api public
  class AssociationSet < ROM::Registry
    # @api private
    def initialize(*)
      super
      elements.values.each do |assoc|
        if assoc.aliased? && !key?(assoc.name)
          elements[assoc.name] = assoc
        end
      end
    end
    ruby2_keywords(:initialize) if respond_to?(:ruby2_keywords, true)
  end
end
