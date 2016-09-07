require 'pathname'

require 'rom/support/constants'
require 'rom/support/inflector'
require 'rom/support/options'

module ROM
  class AutoRegistration
    EXTENSION_REGEX = /\.rb$/.freeze

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
        klass_name = case
        when namespace.class == String
          CustomNamespaceStrategy.new(namespace: namespace, file: file).call
        when namespace == true
          WithNamespaceStrategy.new(file: file, directory: directory).call
        when namespace == false
          NoNamespaceStrategy.new(file: file, directory: directory, entity: component_dirs.fetch(entity)).call
        end
        Inflector.constantize(klass_name)
      end
    end

    class CustomNamespaceStrategy
      include Options
      option :file, reader: true, type: String
      option :namespace, reader: true, type: String

      def call
        "#{namespace}::#{Inflector.camelize(filename).sub(EXTENSION_REGEX, '')}"
      end

      private

      attr_reader :namespace, :file

      def filename
        Pathname.new(file).basename.to_s
      end
    end

    class WithNamespaceStrategy
      include Options
      option :directory, reader: true, type: Pathname
      option :file, reader: true, type: String

      def call
        Inflector.camelize(
          file.sub(/^#{directory.dirname}\//, '').sub(EXTENSION_REGEX, '')
        )
      end

      private

      attr_reader :directory, :file
    end

    class NoNamespaceStrategy
      include Options
      option :directory, reader: true, type: Pathname
      option :file, reader: true, type: String
      option :entity, reader: true, type: Symbol

      def call
        Inflector.camelize(
          file.sub(/^#{directory}\/#{entity}\//, '').sub(EXTENSION_REGEX, '')
        )
      end

      private

      attr_reader :directory, :file, :entity
    end
  end
end
