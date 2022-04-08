# frozen_string_literal: true

require "rom/registries/root"

module ROM
  # @api public
  class Registries::Root
    option :notifications, optional: true

    # @api private
    # @api deprecated
    def trigger(event, payload)
      notifications&.trigger(event, payload)
    end

    # @api public
    # @deprecated
    def map_with(*ids)
      with(opts: {map_with: ids})
    end

    undef :build
    # @api private
    def build(key, &block)
      item = components.(key, &block)

      if commands? && (mappers = opts[:map_with])
        item >> mappers.map { |mapper| item.relation.mappers[mapper] }.reduce(:>>)
      else
        item
      end
    end

    private

    # @api private
    def respond_to_missing?(name, *)
      super || key?(name)
    end

    # @api public
    # @deprecated
    def method_missing(name, *args, &block)
      fetch(name) { super }
    end
  end
end
