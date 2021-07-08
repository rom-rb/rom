# frozen_string_literal: true

require "dry/configurable"
require "dry/transformer"

require "rom/processor/transformer"

module ROM
  # Transformer is a data mapper which uses `Dry::Transformer`'s DSL to define transformations.
  #
  # @api public
  class Transformer < Dry::Transformer[Processor::Transformer::Functions]
    extend Dry::Configurable

    setting :component do
      setting :id
      setting :relation
    end

    # @api private
    def self.infer_option(option, component:)
      case option
      when :id
        component.constant.register_as ||
          component.constant.relation ||
          Inflector.component_id(component.constant.name).to_sym
      when :relation_id
        component.constant.relation
      end
    end

    # Configure relation for the transformer
    #
    # @example with a custom name
    #   class UsersMapper < ROM::Transformer
    #     relation :users, as: :json_serializer
    #
    #     map do
    #       rename_keys user_id: :id
    #       deep_stringify_keys
    #     end
    #   end
    #
    #   users.map_with(:json_serializer)
    #
    # @param name [Symbol]
    # @param options [Hash]
    # @option options :as [Symbol] Mapper identifier
    #
    # @api public
    def self.relation(name = Undefined, as: name)
      if name == Undefined
        config.component.relation
      else
        config.component.relation = name
        config.component.id = as
      end
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
