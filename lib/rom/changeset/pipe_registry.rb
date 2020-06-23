# frozen_string_literal: true

require "dry/transformer/all"
require "dry/transformer/registry"

module ROM
  class Changeset
    # Transproc Registry useful for pipe
    #
    # @api private
    module PipeRegistry
      extend Dry::Transformer::Registry

      import Dry::Transformer::Coercions
      import Dry::Transformer::HashTransformations

      def self.add_timestamps(data)
        now = Time.now
        Hash(created_at: now, updated_at: now).merge(data)
      end

      def self.touch(data)
        Hash(updated_at: Time.now).merge(data)
      end
    end
  end
end
