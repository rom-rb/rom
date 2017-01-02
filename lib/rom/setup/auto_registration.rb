require 'pathname'

require 'dry/core/inflector'

require 'rom/types'
require 'rom/initializer'
require 'rom/setup/auto_registration_strategies/no_namespace'
require 'rom/setup/auto_registration_strategies/with_namespace'
require 'rom/setup/auto_registration_strategies/custom_namespace'

module ROM
  class AutoRegistration
    extend Initializer

    NamespaceType = Types::Strict::Bool | Types::Strict::String
    PathnameType = Types.Constructor(Pathname, &Kernel.method(:Pathname))

    param :directory, type: PathnameType

    option :namespace, reader: true, type: NamespaceType, default: proc { true }

    option :component_dirs, reader: true, type: Types::Strict::Hash, default: proc { {
      relations: :relations,
      mappers: :mappers,
      commands: :commands
    } }

    option :globs, reader: true, default: -> r {
      Hash[
        component_dirs.map { |component, directory|
          [component, r.directory.join("#{directory}/**/*.rb")]
        }
      ]
    }

    def relations
      load_entities(:relations)
    end

    def commands
      load_entities(:commands)
    end

    def mappers
      load_entities(:mappers)
    end

    private

    def load_entities(entity)
      Dir[globs[entity]].map do |file|
        require file
        klass_name =
          case namespace
          when String
            AutoRegistrationStrategies::CustomNamespace.new(
              namespace: namespace, file: file
            ).call
          when TrueClass
            AutoRegistrationStrategies::WithNamespace.new(
              file: file, directory: directory
            ).call
          when FalseClass
            AutoRegistrationStrategies::NoNamespace.new(
              file: file, directory: directory, entity: component_dirs.fetch(entity)
            ).call
          end
        Dry::Core::Inflector.constantize(klass_name)
      end
    end
  end
end
