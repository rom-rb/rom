# frozen_string_literal: true

require_relative "nestable"

module ROM
  module Registries
    class Mappers < Root
      prepend Nestable

      # @api private
      def import(mappers)
        container.namespace(namespace) do |namespace|
          mappers.each do |name, mapper|
            namespace.register(name, mapper)
          end
        end
        self
      end
    end
  end
end
