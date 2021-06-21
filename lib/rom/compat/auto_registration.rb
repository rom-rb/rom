# frozen_string_literal: true

require "pathname"

require "rom/support/inflector"

require "rom/types"
require "rom/initializer"

require_relative "auto_registration_strategies/no_namespace"
require_relative "auto_registration_strategies/with_namespace"
require_relative "auto_registration_strategies/custom_namespace"

module ROM
  # AutoRegistration is used to load component files automatically from the provided directory path
  #
  # @api public
  class AutoRegistration
    extend Initializer

    NamespaceType = Types::Strict::Bool | Types::Strict::String

    PathnameType = Types.Constructor(Pathname, &Kernel.method(:Pathname))

    InflectorType = Types.Strict(Dry::Inflector)

    DEFAULT_MAPPING = {
      relations: :relations,
      mappers: :mappers,
      commands: :commands
    }.freeze

    # @!attribute [r] directory
    #   @return [Pathname] The root path
    param :directory, type: PathnameType

    # @!attribute [r] namespace
    #   @return [Boolean,String]
    #     The name of the top level namespace or true/false which
    #     enables/disables default top level namespace inferred from the dir name
    option :namespace, type: NamespaceType, default: -> { true }

    # @!attribute [r] component_dirs
    #   @return [Hash] component => dir-name map
    option :component_dirs, type: Types::Strict::Hash, default: -> { DEFAULT_MAPPING }

    # @!attribute [r] globs
    #   @return [Hash] File globbing functions for each component dir
    option :globs, default: lambda {
      component_dirs.map { |component, path|
        [component, directory.join("#{path}/**/*.rb")]
      }.to_h
    }

    # @!attribute [r] inflector
    #   @return [Dry::Inflector] String inflector
    #   @api private
    option :inflector, type: InflectorType, default: -> { Inflector }

    # Load relation files
    #
    # @api private
    def relations
      load_entities(:relations)
    end

    # Load command files
    #
    # @api private
    def commands
      load_entities(:commands)
    end

    # Load mapper files
    #
    # @api private
    def mappers
      load_entities(:mappers)
    end

    private

    # Load given component files
    #
    # @api private
    def load_entities(entity)
      Dir[globs[entity]].sort.map do |file|
        require file
        klass_name =
          case namespace
          when String
            AutoRegistrationStrategies::CustomNamespace.new(
              namespace: namespace,
              file: file,
              directory: directory,
              inflector: inflector
            ).call
          when TrueClass
            AutoRegistrationStrategies::WithNamespace.new(
              file: file, directory: directory, inflector: inflector
            ).call
          when FalseClass
            AutoRegistrationStrategies::NoNamespace.new(
              file: file,
              directory: directory,
              entity: component_dirs.fetch(entity),
              inflector: inflector
            ).call
          end

        inflector.constantize(klass_name)
      end
    end
  end
end
