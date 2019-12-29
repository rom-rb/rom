# frozen_string_literal: true

require 'transproc/all'
require 'transproc/registry'

module ROM
  class Changeset
    # Transproc Registry useful for pipe
    #
    # @api private
    module PipeRegistry
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::HashTransformations

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
