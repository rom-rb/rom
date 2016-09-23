require 'pathname'

require 'rom/support/constants'
require 'rom/support/inflector'
require 'rom/support/options'

module ROM
  class AutoRegistration

    include Options

    option :namespace, reader: true, type: [TrueClass, FalseClass, String], default: true
    option :component_dirs, reader: true, type: ::Hash, default: {
      relations: :relations,
      mappers: :mappers,
      commands: :commands
    }

    attr_reader :globs, :directory

    def initialize(directory, options = EMPTY_HASH)
      super
      @directory = Pathname(directory)
      @globs = Hash[component_dirs.map { |component, directory|
        [component, @directory.join("#{directory}/**/*.rb")]
      }]
    end

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
        klass_name = case namespace
        when String
          AutoRegistrationStrategies::CustomNamespace.new(namespace: namespace, file: file).call
        when TrueClass
          AutoRegistrationStrategies::WithNamespace.new(file: file, directory: directory).call
        when FalseClass
          AutoRegistrationStrategies::NoNamespace.new(file: file, directory: directory, entity: component_dirs.fetch(entity)).call
        end
        Inflector.constantize(klass_name)
      end
    end



  end
end
