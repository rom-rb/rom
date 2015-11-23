require 'pathname'

require 'rom/support/constants'
require 'rom/support/inflector'
require 'rom/support/options'

module ROM
  class AutoRegistration
    include Options

    option :namespace, reader: true, type: [TrueClass, FalseClass], default: true

    attr_reader :globs, :directory

    def initialize(directory, options = EMPTY_HASH)
      super
      @directory = directory
      @globs = Hash[[:relations, :commands, :mappers].map { |name|
        [name, Pathname(directory).join("#{name}/**/*.rb")]
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
        Inflector.constantize(const_name(entity, file))
      end
    end

    def const_name(entity, file)
      name =
        if namespace
          file.gsub("#{directory.dirname}/", '')
        else
          file.gsub("#{directory}/#{entity}/", '')
        end.gsub('.rb', '')

      Inflector.camelize(name)
    end
  end
end
