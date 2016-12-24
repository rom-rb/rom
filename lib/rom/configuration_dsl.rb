require 'rom/configuration_dsl/relation'
require 'rom/configuration_dsl/mapper_dsl'
require 'rom/configuration_dsl/command_dsl'

module ROM
  # This extends Configuration class with the DSL methods
  #
  # @api public
  module ConfigurationDSL
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
      register_relation(klass)
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
      register_mapper(*MapperDSL.new(self, mapper_classes, block).mapper_classes)
    end

    # Command definition DSL
    #
    # @example
    #
    #   setup.commands(:users) do
    #     define(:create) do
    #       input NewUserParams
    #       result :one
    #     end
    #
    #     define(:update) do
    #       input UserParams
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
      register_command(*CommandDSL.new(name, default_adapter, &block).command_classes)
    end
  end
end
