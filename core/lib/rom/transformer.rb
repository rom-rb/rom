# frozen_string_literal: true

require 'dry/core/class_attributes'
require 'transproc/transformer'

require 'rom/processor/transproc'

module ROM
  # Transformer is a data mapper which uses Transproc's transformer DSL to define
  # transformations.
  #
  # @api public
  class Transformer < Transproc::Transformer[ROM::Processor::Transproc::Functions]
    extend Dry::Core::ClassAttributes

    defines :relation, :register_as

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
    def self.relation(name = Undefined, options = EMPTY_HASH)
      return @relation if name.equal?(Undefined) && defined?(@relation)
      register_as(options.fetch(:as, name))
      super(name)
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

    # This is needed to make transformers compatible with rom setup
    #
    # @api private
    def self.base_relation
      relation
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
