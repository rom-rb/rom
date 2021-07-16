# frozen_string_literal: true

require "dry/transformer"

require_relative "components/provider"
require_relative "processor/transformer"

module ROM
  # Transformer is a data mapper which uses `Dry::Transformer`'s DSL to define transformations.
  #
  # @api public
  class Transformer < Dry::Transformer[Processor::Transformer::Functions]
    extend ROM::Provider(type: :mapper)

    setting :component do
      setting :type, default: :mapper
      setting :id
      setting :relation
      setting :namespace, default: "mappers"
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
