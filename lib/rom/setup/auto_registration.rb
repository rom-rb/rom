require 'pathname'

require 'rom/support/constants'
require 'rom/support/inflector'
require 'rom/support/options'

module ROM
  class AutoRegistration
    EXTENSION_REGEX = /\.rb$/.freeze

    include Options

    option :namespace, reader: true, type: [TrueClass, FalseClass], default: true
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
        Inflector.constantize(
          const_name(component_dirs.fetch(entity), file)
        )
      end
    end

    def const_name(entity, file)
      name =
        if namespace
          file.sub(/^#{directory.dirname}\//, '')
        else
          file.sub(/^#{directory}\/#{entity}\//, '')
        end.sub(EXTENSION_REGEX, '')

      Inflector.camelize(name)
    end
  end
end
