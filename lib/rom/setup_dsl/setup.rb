require 'rom/setup_dsl/relation'

require 'rom/setup_dsl/mapper_dsl'
require 'rom/setup_dsl/command_dsl'

module ROM
  # This extends Setup class with the DSL methods
  #
  # @api public
  class Setup
    # Relation definition DSL
    #
    # @example
    #
    #   setup.relation(:users) do
    #     def names
    #       project(:name)
    #     end
    #   end
    #
    # @api public
    def relation(name, options = EMPTY_HASH, &block)
      klass_opts = { adapter: default_adapter }.merge(options)
      klass = Relation.build_class(name, klass_opts)
      klass.register_as(name)
      klass.class_eval(&block) if block
      klass
    end

    # Mapper definition DSL
    #
    # @example
    #
    #   setup.mappers do
    #     define(:users) do
    #       model name: 'User'
    #     end
    #
    #     define(:names, parent: :users) do
    #       exclude :id
    #     end
    #   end
    #
    # @api public
    def mappers(&block)
      MapperDSL.new(self, &block)
    end

    # Command definition DSL
    #
    # @example
    #
    #   setup.commands(:users) do
    #     define(:create) do
    #       input NewUserParams
    #       validator NewUserValidator
    #       result :one
    #     end
    #
    #     define(:update) do
    #       input UserParams
    #       validator UserValidator
    #       result :many
    #     end
    #
    #     define(:delete) do
    #       result :many
    #     end
    #   end
    #
    # @api public
    def commands(name, &block)
      CommandDSL.new(name, default_adapter, &block)
    end
  end
end
