# frozen_string_literal: true

require 'dry/core/class_attributes'
require 'dry/transformer'

require 'rom/processor/transformer'

module ROM
  # Transformer is a data mapper which uses `Dry::Transformer`'s DSL to define transformations.
  #
  # @api public
  class Transformer < Dry::Transformer[Processor::Transformer::Functions]
    extend Dry::Core::ClassAttributes

    # @!method self.register_as
    #  Get or set registration name
    #
    #  @overload register_as
    #    Return the registration name
    #    @return [Symbol]
    #
    #  @overload register_as(name)
    #    Configure registration name
    #
    #    @example
    #      class MyMapper < ROM::Transformer
    #        relation :users
    #        register_as :my_mapper
    #      end
    #
    #    @param name [Symbol] The registration name
    defines :register_as

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
      @relation = name
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
