# frozen_string_literal: true

require 'rom/registry'

module ROM
  # @api private
  class RelationRegistry < Registry
    # @api private
    def initialize(elements = {}, **options)
      super
      yield(self, elements) if block_given?
    end
  end
end
