# frozen_string_literal: true

require "dry/configurable"
require "dry/transformer"

require "rom/components"
require "rom/processor/transformer"

module ROM
  # Transformer is a data mapper which uses `Dry::Transformer`'s DSL to define transformations.
  #
  # @api public
  class Transformer < Dry::Transformer[Processor::Transformer::Functions]
    extend ROM.Components
    extend Dry::Configurable

    setting :component do
      setting :id, default: -> (config) { config.component.relation_id }
      setting :relation_id
      setting :namespace, default: -> (config) { "mappers.#{config.component.relation_id}" }
    end

    # Define transformation pipeline
    #
    # @example
    #   class UsersMapper < ROM::Transformer
    #     map do
    #       rename_keys user_id: :id
    #       deep_stringify_keys
    #     end
    #   end
    #
    # @return [self]
    #
    # @api public
    def self.map(&block)
      define! do
        map_array(&block)
      end
    end

    # Build a mapper instance
    #
    # @return [Transformer]
    #
    # @api public
    def self.build
      new
    end
  end
end
